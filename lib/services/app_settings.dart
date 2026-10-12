import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Profile and appearance settings, stored on the device.
class AppSettings extends ChangeNotifier {
  static const _kUsername = 'username';
  static const _kAvatar = 'avatarPath';
  static const _kThemeMode = 'themeMode';
  static const _kPalette = 'palette';
  static const _kHighContrast = 'highContrast';
  static const _kGoal = 'yearlyGoal';

  final SharedPreferences _prefs;

  String? _username;
  String? _avatarPath;
  ThemeMode _themeMode = ThemeMode.dark;
  String _paletteId = 'purple';
  bool _highContrast = false;
  int _yearlyGoal = 0;

  /// Hook for the future server: return an error message when the username
  /// is taken (or the server is unreachable), or null when it is available.
  Future<String?> Function(String username)? usernameAvailabilityCheck;

  AppSettings._(this._prefs) {
    _username = _prefs.getString(_kUsername);
    _avatarPath = _prefs.getString(_kAvatar);
    _paletteId = _prefs.getString(_kPalette) ?? 'purple';
    _highContrast = _prefs.getBool(_kHighContrast) ?? false;
    _yearlyGoal = _prefs.getInt(_kGoal) ?? 0;
    switch (_prefs.getString(_kThemeMode)) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'system':
        _themeMode = ThemeMode.system;
        break;
      default:
        _themeMode = ThemeMode.dark;
    }
    // Forget an avatar whose file has disappeared.
    if (_avatarPath != null && !File(_avatarPath!).existsSync()) {
      _avatarPath = null;
    }
  }

  static Future<AppSettings> load() async =>
      AppSettings._(await SharedPreferences.getInstance());

  String? get username => _username;
  String? get avatarPath => _avatarPath;
  ThemeMode get themeMode => _themeMode;
  String get paletteId => _paletteId;
  bool get highContrast => _highContrast;

  /// Books to finish this year (0 = no goal set).
  int get yearlyGoal => _yearlyGoal;

  /// Local rules for usernames. Returns an error message or null.
  static String? validateUsername(String value) {
    final v = value.trim();
    if (v.length < 3) return 'At least 3 characters.';
    if (v.length > 24) return 'At most 24 characters.';
    if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(v)) {
      return 'Use letters, numbers, dot, dash or underscore.';
    }
    return null;
  }

  Future<void> setUsername(String? value) async {
    final v = value?.trim();
    if (v == null || v.isEmpty) {
      _username = null;
      await _prefs.remove(_kUsername);
    } else {
      _username = v;
      await _prefs.setString(_kUsername, v);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_kThemeMode, mode.name);
    notifyListeners();
  }

  Future<void> setPalette(String id) async {
    _paletteId = id;
    await _prefs.setString(_kPalette, id);
    notifyListeners();
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    await _prefs.setBool(_kHighContrast, value);
    notifyListeners();
  }

  Future<void> setYearlyGoal(int value) async {
    _yearlyGoal = value < 0 ? 0 : value;
    await _prefs.setInt(_kGoal, _yearlyGoal);
    notifyListeners();
  }

  /// Lets the user pick a picture and stores a copy inside the app folder.
  /// Returns false when the user cancelled or something went wrong.
  Future<bool> changeAvatar() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 768,
        maxHeight: 768,
        imageQuality: 88,
      );
      if (picked == null) return false;

      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'profile'));
      if (!await dir.exists()) await dir.create(recursive: true);

      // New file name each time so Flutter does not show a cached old image.
      final ext = p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
      final target = File(
        p.join(dir.path, 'avatar_${DateTime.now().millisecondsSinceEpoch}$ext'),
      );
      await File(picked.path).copy(target.path);

      await _deleteOldAvatar();
      _avatarPath = target.path;
      await _prefs.setString(_kAvatar, target.path);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> removeAvatar() async {
    await _deleteOldAvatar();
    _avatarPath = null;
    await _prefs.remove(_kAvatar);
    notifyListeners();
  }

  Future<void> _deleteOldAvatar() async {
    final old = _avatarPath;
    if (old == null) return;
    try {
      final f = File(old);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
