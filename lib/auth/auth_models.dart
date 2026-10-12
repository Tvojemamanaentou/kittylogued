enum AuthProviderType { email, google, facebook, microsoft }

/// The signed-in user as the app sees it, whatever provider was used.
class AuthUser {
  final String id;
  final AuthProviderType provider;
  final String? email;
  final String? displayName;

  const AuthUser({
    required this.id,
    required this.provider,
    this.email,
    this.displayName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'provider': provider.name,
    'email': email,
    'displayName': displayName,
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    provider: AuthProviderType.values.firstWhere(
      (p) => p.name == json['provider'],
      orElse: () => AuthProviderType.email,
    ),
    email: json['email'] as String?,
    displayName: json['displayName'] as String?,
  );
}
