import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kittylogued/auth/auth_brain.dart';
import 'package:kittylogued/auth/auth_models.dart';
import 'package:kittylogued/auth/email_auth_brain.dart';
import 'package:kittylogued/auth/facebook_auth_brain.dart';
import 'package:kittylogued/auth/google_auth_brain.dart';
import 'package:kittylogued/auth/microsoft_auth_brain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the active signed-in user and keeps the login state in sync with the
/// browser / app storage layer. The class deliberately keeps this logic small,
/// readable, and easy to test: it does not perform arbitrary JSON mutation and it
/// validates the restored session before trusting it.
class AuthService extends ChangeNotifier {
  // Keep the existing key so users who were already signed in stay signed in.
  static const _kUserKey = 'authUser';
  static const _kMaxPersistedUserSize = 4096;

  final SharedPreferences _prefs;
  final Map<AuthProviderType, AuthBrain> _brains;
  AuthUser? _user;

  AuthService._(this._prefs, Map<AuthProviderType, AuthBrain> brains)
    : _brains = Map.unmodifiable(brains) {
    _rehydrateUser();
  }

  static Future<AuthService> load() async {
    final brains = <AuthProviderType, AuthBrain>{
      AuthProviderType.email: EmailAuthBrain(),
      AuthProviderType.google: GoogleAuthBrain(),
      AuthProviderType.facebook: FacebookAuthBrain(),
      AuthProviderType.microsoft: MicrosoftAuthBrain(),
    };

    return AuthService._(await SharedPreferences.getInstance(), brains);
  }

  AuthUser? get user => _user;
  bool get isSignedIn => _user != null;

  void _rehydrateUser() {
    final raw = _prefs.getString(_kUserKey);
    if (raw == null || raw.trim().isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        _prefs.remove(_kUserKey);
        _user = null;
        return;
      }

      _user = AuthUser.fromJson(decoded);
    } catch (_) {
      _user = null;
      _prefs.remove(_kUserKey);
    }
  }

  Future<void> _persistUser() async {
    if (_user == null) {
      await _prefs.remove(_kUserKey);
      return;
    }

    final payload = jsonEncode(_user!.toJson());
    if (payload.length > _kMaxPersistedUserSize) {
      await _prefs.remove(_kUserKey);
      _user = null;
      return;
    }

    await _prefs.setString(_kUserKey, payload);
  }

  Future<void> signIn(
    AuthProviderType type, {
    String? email,
    String? password,
  }) async {
    final brain = _brains[type];
    if (brain == null) {
      throw StateError('Unsupported auth provider: $type');
    }

    final nextUser = await brain.signIn(email: email, password: password);
    if (nextUser.id.trim().isEmpty) {
      throw StateError('Authentication returned an empty user id.');
    }

    _user = nextUser;
    await _persistUser();
    notifyListeners();
  }

  Future<void> signOut() async {
    final current = _user;
    if (current != null) {
      final brain = _brains[current.provider];
      await brain?.signOut();
    }

    _user = null;
    await _prefs.remove(_kUserKey);
    notifyListeners();
  }
}
