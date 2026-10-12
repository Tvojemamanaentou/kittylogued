import 'package:kittylogued/auth/auth_brain.dart';
import 'package:kittylogued/auth/auth_models.dart';

/// Microsoft sign-in. STUB: signs in instantly without contacting anything.
///
/// TODO: use Microsoft identity (MSAL / OAuth), send the token to your server
class MicrosoftAuthBrain implements AuthBrain {
  @override
  AuthProviderType get type => AuthProviderType.microsoft;

  @override
  Future<AuthUser> signIn({String? email, String? password}) async {
    return AuthUser(
      id: 'stub-microsoft',
      provider: type,
      email: (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : 'reader@outlook.com',
      displayName: 'Microsoft reader',
    );
  }

  @override
  Future<void> signOut() async {
    // TODO: end the Microsoft session here.
  }
}
