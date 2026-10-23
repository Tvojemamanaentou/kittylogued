/// Input validation shared by the authentication form.
class AuthValidation {
  const AuthValidation._();

  static String? identifier(String? value, {required bool isEmail}) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) {
      return isEmail ? 'Enter your email address.' : 'Enter your phone number.';
    }

    if (isEmail && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(cleaned)) {
      return 'Please use a valid email address.';
    }
    if (!isEmail && !RegExp(r'^\+?[0-9\s()-]{7,20}$').hasMatch(cleaned)) {
      return 'Please use a valid phone number.';
    }

    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  static String? username(String? value) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) {
      return 'Username is required to create an account.';
    }
    if (cleaned.length < 3) {
      return 'Username must be at least 3 characters long.';
    }
    if (cleaned.length > 24) {
      return 'Username must be at most 24 characters long.';
    }
    if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(cleaned)) {
      return 'Use letters, numbers, dot, dash or underscore.';
    }
    return null;
  }
}
