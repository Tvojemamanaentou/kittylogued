import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kittylogued/auth/auth_brain.dart';
import 'package:kittylogued/auth/auth_models.dart';
import 'package:kittylogued/auth/email_auth_brain.dart';
import 'package:kittylogued/auth/facebook_auth_brain.dart';
import 'package:kittylogued/auth/google_auth_brain.dart';
import 'package:kittylogued/auth/microsoft_auth_brain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps track of who is signed in and delegates to the provider brains.
class AuthService extends ChangeNotifier {
  static const _kUser = 'authUser';

  final SharedPreferences _prefs;
  final Map<AuthProviderType, AuthBrain> _brains;
  AuthUser? _user;

  AuthService._(this._prefs, this._brains) {
    final raw = _prefs.getString(_kUser);
    if (raw != null) {
      try {
        _user = AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _user = null;
      }
    }
  }

  static Future<AuthService> load() async {
    final brains = <AuthProviderType, AuthBrain>{
      AuthProviderType.email: EmailAuthBrain(),
      AuthProviderType.google: GoogleAuthBrain(),
      AuthProviderType.facebook: FacebookAuthBrain(),
      AuthProviderType.microsoft: MicrosoftAuthBrain(),
    };
    return AuthService._(await SharedPreferences.getInstance(), brains);
  }

  AuthUser? get user => _user;
  bool get isSignedIn => _user != null;

  Future<void> signIn(
    AuthProviderType type, {
    String? email,
    String? password,
  }) async {
    final brain = _brains[type]!;
    _user = await brain.signIn(email: email, password: password);
    await _prefs.setString(_kUser, jsonEncode(_user!.toJson()));
    notifyListeners();
  }

  Future<void> signOut() async {
    final current = _user;
    if (current != null) await _brains[current.provider]?.signOut();
    _user = null;
    await _prefs.remove(_kUser);
    notifyListeners();
  }
}
