import 'package:kittylogued/auth/auth_models.dart';

/// The "brain" behind one sign-in method. The UI never talks to a provider
/// directly; it asks [AuthService], which asks the matching brain.
///
/// Every brain below is a stub for now: it signs in instantly with a made-up
/// user. Replace the body of `signIn` / `signOut` with the real provider code
/// when the backend exists; nothing else in the app has to change.
abstract class AuthBrain {
  AuthProviderType get type;

  Future<AuthUser> signIn({String? email, String? password});

  Future<void> signOut();
}
