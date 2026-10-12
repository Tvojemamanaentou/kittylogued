import 'package:kittylogued/auth/auth_brain.dart';
import 'package:kittylogued/auth/auth_models.dart';

/// Google sign-in. STUB: signs in instantly without contacting anything.
///
/// TODO: use a Google sign-in package, send the Google token to your server
class GoogleAuthBrain implements AuthBrain {
  @override
  AuthProviderType get type => AuthProviderType.google;

  @override
  Future<AuthUser> signIn({String? email, String? password}) async {
    return AuthUser(
      id: 'stub-google',
      provider: type,
      email: (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : 'reader@gmail.com',
      displayName: 'Google reader',
    );
  }

  @override
  Future<void> signOut() async {
    // TODO: end the Google session here.
  }
}
