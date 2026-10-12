import 'package:flutter/material.dart';
import 'package:kittylogued/auth/auth_models.dart';
import 'package:kittylogued/services/auth_service.dart';

/// Simple sign-in screen. For now every button signs in straight away
/// (the real logic lives in the brains under lib/auth/).
class SignInPage extends StatefulWidget {
  final AuthService auth;

  const SignInPage({super.key, required this.auth});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn(AuthProviderType type) async {
    setState(() => _busy = true);
    await widget.auth.signIn(
      type,
      email: _email.text,
      password: _password.text,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Icon(Icons.pets, size: 56, color: scheme.primary),
              const SizedBox(height: 8),
              const Text(
                'Welcome to Kittylogued',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _busy ? null : _signIn(AuthProviderType.email),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : () => _signIn(AuthProviderType.email),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Sign in with email'),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              _providerButton(
                icon: Icons.g_mobiledata,
                label: 'Continue with Google',
                type: AuthProviderType.google,
              ),
              const SizedBox(height: 10),
              _providerButton(
                icon: Icons.facebook,
                label: 'Continue with Facebook',
                type: AuthProviderType.facebook,
              ),
              const SizedBox(height: 10),
              _providerButton(
                icon: Icons.window,
                label: 'Continue with Microsoft',
                type: AuthProviderType.microsoft,
              ),
              const SizedBox(height: 20),
              const Text(
                'Preview: signing in is not connected yet, so any button logs you in.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _providerButton({
    required IconData icon,
    required String label,
    required AuthProviderType type,
  }) {
    return OutlinedButton.icon(
      onPressed: _busy ? null : () => _signIn(type),
      icon: Icon(icon, size: 24),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label),
      ),
    );
  }
}
