import 'package:dio/dio.dart';

import 'package:kittylogued/api/api_client.dart';
import 'package:kittylogued/api/api_exceptions.dart';
import 'package:kittylogued/api/dtos/auth_dtos.dart';

class AuthApiService {
  final ApiClient client;

  AuthApiService({required this.client});

  Future<UsernameCheckResponse> checkUsernameAvailability(
    String username,
  ) async {
    final clean = username.trim();
    if (clean.isEmpty) {
      throw const BadRequestException(message: 'Username cannot be empty.');
    }
    final response = await client.get<Map<String, dynamic>>(
      '/auth/username-check',
      queryParameters: {'username': clean},
    );
    return UsernameCheckResponse.fromJson(response.data!);
  }

  Future<UsernameCheckResponse> checkUsername(String username) =>
      checkUsernameAvailability(username);

  Future<AuthSessionDto> signUpWithCredentials(CredentialSignUpDto dto) async {
    final response = await client.post<Map<String, dynamic>>(
      '/auth/signup/credentials',
      data: dto.toJson(),
    );
    return AuthSessionDto.fromJson(response.data!);
  }

  Future<AuthSessionDto> signInWithCredentials(CredentialSignInDto dto) async {
    final response = await client.post<Map<String, dynamic>>(
      '/auth/signin/credentials',
      data: dto.toJson(),
    );
    return AuthSessionDto.fromJson(response.data!);
  }

  Future<AuthSessionDto> signInWithOAuth(OAuthSignInDto dto) async {
    final response = await client.post<Map<String, dynamic>>(
      '/auth/oauth',
      data: dto.toJson(),
    );
    return AuthSessionDto.fromJson(response.data!);
  }

  Future<UserProfileDto> getMe(String token) async {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty) {
      throw const UnauthorizedException(
        message: 'A session token is required.',
      );
    }
    final response = await client.get<Map<String, dynamic>>(
      '/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $cleanToken'}),
    );
    final data = response.data;
    if (data == null) {
      throw const ApiException(
        message: 'The server returned an empty profile.',
      );
    }
    return UserProfileDto.fromJson(data);
  }

  Future<UserProfileDto> registerUser(RegisterUserRequest request) async {
    final response = await client.post<Map<String, dynamic>>(
      '/auth/register',
      data: request.toJson(),
    );
    return UserProfileDto.fromJson(response.data!);
  }
}
