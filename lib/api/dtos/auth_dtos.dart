class UsernameCheckResponse {
  final String username;
  final bool available;

  const UsernameCheckResponse({
    required this.username,
    required this.available,
  });

  factory UsernameCheckResponse.fromJson(Map<String, dynamic> json) {
    return UsernameCheckResponse(
      username: json['username'] as String? ?? '',
      available: json['available'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'available': available,
      };
}

class RegisterUserRequest {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;

  const RegisterUserRequest({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'display_name': displayName,
        'avatar_url': avatarUrl,
      };
}

class UserProfileDto {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final DateTime? createdAt;

  const UserProfileDto({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.createdAt,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      createdAt: json['created_at'] != null && (json['created_at'] as String).isNotEmpty
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}

class AuthSessionDto {
  final String token;
  final DateTime expiresAt;
  final UserProfileDto user;
  final String provider;
  final String providerUid;

  const AuthSessionDto({
    required this.token,
    required this.expiresAt,
    required this.user,
    required this.provider,
    required this.providerUid,
  });

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      token: json['token'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      user: UserProfileDto.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      provider: json['provider'] as String? ?? '',
      providerUid: json['provider_uid'] as String? ?? '',
    );
  }
}

class CredentialSignUpDto {
  final String provider; // 'email' or 'phone'
  final String identifier;
  final String password;
  final String username;
  final String displayName;
  final String avatarUrl;

  CredentialSignUpDto({
    required this.provider,
    required this.identifier,
    required this.password,
    required this.username,
    this.displayName = '',
    this.avatarUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'identifier': identifier,
        'password': password,
        'username': username,
        'display_name': displayName,
        'avatar_url': avatarUrl,
      };
}

class CredentialSignInDto {
  final String provider; // 'email' or 'phone'
  final String identifier;
  final String password;

  CredentialSignInDto({
    required this.provider,
    required this.identifier,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'identifier': identifier,
        'password': password,
      };
}

class OAuthSignInDto {
  final String provider; // 'google', 'github', 'microsoft', 'facebook'
  final String providerUid;
  final String email;
  final String username;
  final String displayName;
  final String avatarUrl;

  OAuthSignInDto({
    required this.provider,
    required this.providerUid,
    this.email = '',
    this.username = '',
    this.displayName = '',
    this.avatarUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'provider_uid': providerUid,
        if (email.isNotEmpty) 'email': email,
        if (username.isNotEmpty) 'username': username,
        if (displayName.isNotEmpty) 'display_name': displayName,
        if (avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
      };
}
