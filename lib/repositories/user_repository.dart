import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kittylogued/api/api_exceptions.dart';
import 'package:kittylogued/api/dtos/auth_dtos.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/services/auth_api_service.dart';

class UserRepository {
  static const _kSessionToken = 'auth_session_token';

  final AuthApiService _apiService;
  final AppDatabase _db;

  factory UserRepository({
    required AuthApiService apiService,
    required AppDatabase db,
  }) {
    return UserRepository._(apiService, db);
  }

  UserRepository._(this._apiService, this._db);

  Future<String?> checkUsernameAvailability(String username) async {
    final clean = username.trim();
    if (clean.length < 3) {
      return 'Username must be at least 3 characters long.';
    }
    try {
      final res = await _apiService.checkUsernameAvailability(clean);
      return res.available ? null : 'Username "$clean" is already taken.';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<User> handleAuthSession(AuthSessionDto session) async {
    final token = session.token.trim();
    final userId = session.user.id.trim();
    if (token.isEmpty || userId.isEmpty) {
      throw const FormatException('The authentication response is incomplete.');
    }

    final user = await _saveCurrentUser(
      id: userId,
      username: session.user.username,
      displayName: session.user.displayName,
      avatarUrl: session.user.avatarUrl,
      createdAt: session.user.createdAt,
    );

    // Only persist a token after the local account update has succeeded.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSessionToken, token);
    return user;
  }

  /// Atomically switches the active local account and updates its profile.
  Future<User> _saveCurrentUser({
    required String id,
    required String username,
    required String displayName,
    required String avatarUrl,
    required DateTime? createdAt,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.users)..where((user) => user.isMe.equals(true)))
          .write(const UsersCompanion(isMe: Value(false)));

      final existing = await (_db.select(
        _db.users,
      )..where((user) => user.uid.equals(id))).getSingleOrNull();

      if (existing == null) {
        await _db
            .into(_db.users)
            .insert(
              UsersCompanion(
                uid: Value(id),
                username: Value(username),
                displayName: Value(displayName),
                avatarUrl: Value(avatarUrl),
                isMe: const Value(true),
                createdAt: Value(createdAt ?? DateTime.now()),
              ),
            );
      } else {
        await (_db.update(
          _db.users,
        )..where((user) => user.id.equals(existing.id))).write(
          UsersCompanion(
            username: Value(username),
            displayName: Value(displayName),
            avatarUrl: Value(avatarUrl),
            isMe: const Value(true),
          ),
        );
      }

      return (_db.select(
        _db.users,
      )..where((user) => user.uid.equals(id))).getSingle();
    });
  }

  Future<User> signUpWithCredentials(CredentialSignUpDto dto) async {
    final session = await _apiService.signUpWithCredentials(dto);
    return await handleAuthSession(session);
  }

  Future<User> signInWithCredentials(CredentialSignInDto dto) async {
    final session = await _apiService.signInWithCredentials(dto);
    return await handleAuthSession(session);
  }

  Future<User> signInWithOAuth(OAuthSignInDto dto) async {
    final session = await _apiService.signInWithOAuth(dto);
    return await handleAuthSession(session);
  }

  Future<User> registerCurrentUser({
    required String uid,
    required String username,
    required String displayName,
    String avatarUrl = '',
  }) async {
    final profile = await _apiService.registerUser(
      RegisterUserRequest(
        id: uid,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
      ),
    );

    final id = profile.id.trim();
    if (id.isEmpty) {
      throw const FormatException('The profile response is missing a user id.');
    }
    return _saveCurrentUser(
      id: id,
      username: profile.username,
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl,
      createdAt: profile.createdAt,
    );
  }

  Future<User?> getCurrentUser() async {
    return await (_db.select(
      _db.users,
    )..where((tbl) => tbl.isMe.equals(true))).getSingleOrNull();
  }
}
