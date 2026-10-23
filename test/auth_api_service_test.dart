import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/api/api_client.dart';
import 'package:kittylogued/api/api_exceptions.dart';
import 'package:kittylogued/services/auth_api_service.dart';

void main() {
  test('getMe sends the bearer token supplied by the caller', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    String? authorization;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          authorization = options.headers['Authorization'] as String?;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              data: {
                'id': 'user-1',
                'username': 'reader',
                'display_name': 'Reader',
                'avatar_url': '',
              },
            ),
          );
        },
      ),
    );

    final service = AuthApiService(
      client: ApiClient(baseUrl: 'https://example.test', dio: dio),
    );

    final user = await service.getMe('  session-token  ');

    expect(authorization, 'Bearer session-token');
    expect(user.id, 'user-1');
  });

  test('getMe rejects an empty token before making a request', () async {
    final service = AuthApiService(
      client: ApiClient(baseUrl: 'https://example.test'),
    );

    await expectLater(
      service.getMe('  '),
      throwsA(isA<UnauthorizedException>()),
    );
  });
}
