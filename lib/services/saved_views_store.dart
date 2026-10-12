import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A named combination of filters and sorting in the catalogue.
class SavedView {
  final String name;
  final String status; // all, unread, reading, read
  final String shelf; // all or a shelf name
  final List<String> tags;
  final String sortKey;
  final bool ascending;

  const SavedView({
    required this.name,
    required this.status,
    required this.shelf,
    required this.tags,
    required this.sortKey,
    required this.ascending,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'status': status,
    'shelf': shelf,
    'tags': tags,
    'sortKey': sortKey,
    'ascending': ascending,
  };

  factory SavedView.fromJson(Map<String, dynamic> m) => SavedView(
    name: m['name'] as String,
    status: (m['status'] as String?) ?? 'all',
    shelf: (m['shelf'] as String?) ?? 'all',
    tags: ((m['tags'] as List?) ?? const []).map((e) => '$e').toList(),
    sortKey: (m['sortKey'] as String?) ?? 'title',
    ascending: (m['ascending'] as bool?) ?? true,
  );
}

class SavedViewsStore extends ChangeNotifier {
  static const _key = 'savedViews';

  final SharedPreferences _prefs;
  List<SavedView> _views = [];

  SavedViewsStore._(this._prefs) {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      try {
        _views = (jsonDecode(raw) as List)
            .map((e) => SavedView.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _views = [];
      }
    }
  }

  static Future<SavedViewsStore> load() async =>
      SavedViewsStore._(await SharedPreferences.getInstance());

  List<SavedView> get views => List.unmodifiable(_views);

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_views.map((v) => v.toJson()).toList()),
    );
    notifyListeners();
  }

  /// Adds a view, replacing one with the same name.
  Future<void> save(SavedView view) async {
    _views = [
      for (final v in _views)
        if (v.name.toLowerCase() != view.name.toLowerCase()) v,
      view,
    ];
    await _persist();
  }

  Future<void> remove(String name) async {
    _views = _views.where((v) => v.name != name).toList();
    await _persist();
  }
}
