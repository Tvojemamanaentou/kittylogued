import 'package:kittylogued/auth/auth_brain.dart';
import 'package:kittylogued/auth/auth_models.dart';

/// Email sign-in. STUB: signs in instantly without contacting anything.
///
/// TODO: validate email + password against your server (or an auth service), handle sign-up and password reset
class EmailAuthBrain implements AuthBrain {
  @override
  AuthProviderType get type => AuthProviderType.email;

  @override
  Future<AuthUser> signIn({String? email, String? password}) async {
    return AuthUser(
      id: 'stub-email',
      provider: type,
      email: (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : 'reader@example.com',
      displayName: 'Email reader',
    );
  }

  @override
  Future<void> signOut() async {
    // TODO: end the Email session here.
  }
}
