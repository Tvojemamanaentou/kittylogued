import 'package:flutter/material.dart';

import '../api/api_exceptions.dart';
import '../api/dtos/auth_dtos.dart';
import '../repositories/user_repository.dart';
import '../utils/auth_validation.dart';

enum AuthMethod { email, phone }

/// A polished sign-in / sign-up bottom sheet that supports manual credentials and
/// federated OAuth providers. The widget is intentionally self-contained so it can
/// be dropped into the app without wiring a complex state controller.
class MultiAuthDialog extends StatefulWidget {
  const MultiAuthDialog({
    super.key,
    required this.userRepository,
    this.onAuthSuccess,
  });

  final UserRepository userRepository;
  final VoidCallback? onAuthSuccess;

  /// Convenience entry point so callers can present the dialog in one line.
  static Future<void> show(
    BuildContext context, {
    required UserRepository userRepository,
    VoidCallback? onAuthSuccess,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiAuthDialog(
        userRepository: userRepository,
        onAuthSuccess: onAuthSuccess,
      ),
    );
  }

  @override
  State<MultiAuthDialog> createState() => _MultiAuthDialogState();
}

class _MultiAuthDialogState extends State<MultiAuthDialog> {
  // These fields represent the high-level authentication mode.
  bool _isSignUp = false;
  AuthMethod _method = AuthMethod.email;
  bool _loading = false;
  bool _passwordVisible = false;
  String? _errorMessage;

  // A real form is easier to validate, validate on submit, and keep keyboard UX
  // consistent across the fields.
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();

  // Keep the form controls predictable and avoid leaks when the sheet is closed.
  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  /// Validates the auth form before hitting the repository layer.
  bool _validateCredentials() {
    final formIsValid = _formKey.currentState?.validate() ?? false;
    if (formIsValid) {
      setState(() => _errorMessage = null);
    }
    return formIsValid;
  }

  /// Uses the repository to sign in or sign up. All network exceptions are mapped
  /// to user-friendly messages and the sheet is closed on success.
  Future<void> _submitCredentials() async {
    if (_loading || !_validateCredentials()) {
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();
    final displayName = _displayNameController.text.trim();

    try {
      final provider = _method == AuthMethod.email ? 'email' : 'phone';

      if (_isSignUp) {
        await widget.userRepository.signUpWithCredentials(
          CredentialSignUpDto(
            provider: provider,
            identifier: identifier,
            password: password,
            username: username,
            displayName: displayName.isNotEmpty ? displayName : username,
          ),
        );
      } else {
        await widget.userRepository.signInWithCredentials(
          CredentialSignInDto(
            provider: provider,
            identifier: identifier,
            password: password,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      widget.onAuthSuccess?.call();
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(
        () => _errorMessage = 'Authentication failed. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Bottom sheets should feel lightweight and not fight with the keyboard.
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.9),
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sheet grabber for a more native sheet feel.
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),

                  Text(
                    _isSignUp ? 'Create Kittylogued Account' : 'Welcome back',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignUp
                        ? 'Set up your account and start organizing your library.'
                        : 'Sign in to continue managing your collection.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email/phone segmented selector keeps the input method obvious.
                  SegmentedButton<AuthMethod>(
                    segments: const [
                      ButtonSegment(
                        value: AuthMethod.email,
                        label: Text('Email'),
                        icon: Icon(Icons.email_outlined),
                      ),
                      ButtonSegment(
                        value: AuthMethod.phone,
                        label: Text('Phone'),
                        icon: Icon(Icons.phone_android_outlined),
                      ),
                    ],
                    selected: {_method},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _method = selection.first;
                        _errorMessage = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_errorMessage != null) ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Container(
                        key: ValueKey<String>(_errorMessage!),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  ],

                  TextFormField(
                    controller: _identifierController,
                    keyboardType: _method == AuthMethod.email
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => AuthValidation.identifier(
                      value,
                      isEmail: _method == AuthMethod.email,
                    ),
                    decoration: InputDecoration(
                      labelText: _method == AuthMethod.email
                          ? 'Email address'
                          : 'Phone number',
                      prefixIcon: Icon(
                        _method == AuthMethod.email
                            ? Icons.alternate_email
                            : Icons.phone,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onFieldSubmitted: (_) => _submitCredentials(),
                    validator: AuthValidation.password,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _passwordVisible
                            ? 'Hide password'
                            : 'Show password',
                        onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isSignUp) ...[
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: _isSignUp ? AuthValidation.username : null,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _displayNameController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Display name (optional)',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  FilledButton.icon(
                    onPressed: _loading ? null : _submitCredentials,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: Text(_isSignUp ? 'Create account' : 'Sign in'),
                  ),

                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() {
                            _isSignUp = !_isSignUp;
                            _errorMessage = null;
                          }),
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign in'
                          : 'Need an account? Sign up',
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Third-party sign-in will be available when a secure provider flow is configured.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
