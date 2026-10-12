import 'package:kittylogued/auth/auth_brain.dart';
import 'package:kittylogued/auth/auth_models.dart';

/// Facebook sign-in. STUB: signs in instantly without contacting anything.
///
/// TODO: use a Facebook login package, send the access token to your server
class FacebookAuthBrain implements AuthBrain {
  @override
  AuthProviderType get type => AuthProviderType.facebook;

  @override
  Future<AuthUser> signIn({String? email, String? password}) async {
    return AuthUser(
      id: 'stub-facebook',
      provider: type,
      email: (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : 'reader@facebook.com',
      displayName: 'Facebook reader',
    );
  }

  @override
  Future<void> signOut() async {
    // TODO: end the Facebook session here.
  }
}
