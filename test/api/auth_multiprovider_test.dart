import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/api/api_client.dart';
import 'package:kittylogued/api/dtos/auth_dtos.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/repositories/user_repository.dart';
import 'package:kittylogued/services/auth_api_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestPathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;
}

/// In-memory API substitute: keeps repository tests deterministic and offline.
class _FakeAuthApi {
  final Map<String, Map<String, dynamic>> _accounts = {};
  int _nextUserId = 0;

  Dio createClient() {
    final dio = Dio(BaseOptions(baseUrl: 'https://auth.test/api/v1'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final request = Map<String, dynamic>.from(
            options.data as Map? ?? const {},
          );

          switch (options.path) {
            case '/auth/signup/credentials':
              final provider = request['provider'] as String;
              final identifier = request['identifier'] as String;
              final key = '$provider:$identifier';
              final account = {
                'id': 'user-${++_nextUserId}',
                'provider': provider,
                'identifier': identifier,
                'password': request['password'],
                'username': request['username'],
                'display_name': request['display_name'],
                'avatar_url': '',
              };
              _accounts[key] = account;
              handler.resolve(
                Response(requestOptions: options, data: _session(account)),
              );
            case '/auth/signin/credentials':
              final provider = request['provider'] as String;
              final identifier = request['identifier'] as String;
              final account = _accounts['$provider:$identifier'];
              if (account == null ||
                  account['password'] != request['password']) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response(
                      requestOptions: options,
                      statusCode: 401,
                      data: {'message': 'Invalid credentials.'},
                    ),
                    type: DioExceptionType.badResponse,
                  ),
                );
                return;
              }
              handler.resolve(
                Response(requestOptions: options, data: _session(account)),
              );
            case '/auth/oauth':
              final provider = request['provider'] as String;
              final providerUid = request['provider_uid'] as String;
              final account = {
                'id': 'user-${++_nextUserId}',
                'provider': provider,
                'identifier': providerUid,
                'password': null,
                'username': request['username'] ?? '',
                'display_name': request['display_name'] ?? '$provider tester',
                'avatar_url': request['avatar_url'] ?? '',
              };
              _accounts['$provider:$providerUid'] = account;
              handler.resolve(
                Response(requestOptions: options, data: _session(account)),
              );
            default:
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 404,
                    data: {'message': 'Unknown test endpoint.'},
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
          }
        },
      ),
    );
    return dio;
  }

  Map<String, dynamic> _session(Map<String, dynamic> account) => {
    'token': 'test-session-${account['id']}',
    'expires_at': DateTime.utc(2030).toIso8601String(),
    'provider': account['provider'],
    'provider_uid': account['identifier'],
    'user': {
      'id': account['id'],
      'username': account['username'],
      'display_name': account['display_name'],
      'avatar_url': account['avatar_url'],
    },
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _TestPathProvider();

  group('Multi-provider authentication repository', () {
    late AppDatabase database;
    late UserRepository userRepository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      database = AppDatabase.forTesting(NativeDatabase.memory());
      final fakeApi = _FakeAuthApi();
      final apiClient = ApiClient(
        baseUrl: 'https://auth.test/api/v1',
        dio: fakeApi.createClient(),
      );
      userRepository = UserRepository(
        apiService: AuthApiService(client: apiClient),
        db: database,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('email sign up and sign in update the active local user', () async {
      const email = 'reader@example.com';
      const username = 'reader_1';

      final created = await userRepository.signUpWithCredentials(
        CredentialSignUpDto(
          provider: 'email',
          identifier: email,
          password: 'SecretPassword123!',
          username: username,
          displayName: 'Email Reader',
        ),
      );

      expect(created.username, username);
      expect(created.displayName, 'Email Reader');
      expect(created.isMe, isTrue);

      final signedIn = await userRepository.signInWithCredentials(
        CredentialSignInDto(
          provider: 'email',
          identifier: email,
          password: 'SecretPassword123!',
        ),
      );
      expect(signedIn.uid, created.uid);
    });

    test('phone sign up and sign in update the active local user', () async {
      const phone = '+420777123456';

      final created = await userRepository.signUpWithCredentials(
        CredentialSignUpDto(
          provider: 'phone',
          identifier: phone,
          password: 'PhonePass456!',
          username: 'phone_reader',
          displayName: 'Phone Reader',
        ),
      );
      expect(created.isMe, isTrue);

      final signedIn = await userRepository.signInWithCredentials(
        CredentialSignInDto(
          provider: 'phone',
          identifier: phone,
          password: 'PhonePass456!',
        ),
      );
      expect(signedIn.uid, created.uid);
    });

    test('OAuth sessions persist users returned by the provider API', () async {
      final user = await userRepository.signInWithOAuth(
        OAuthSignInDto(
          provider: 'google',
          providerUid: 'verified-provider-subject',
          email: 'google@example.com',
          displayName: 'Google Reader',
        ),
      );

      expect(user.isMe, isTrue);
      expect(user.displayName, 'Google Reader');
    });
  });
}
