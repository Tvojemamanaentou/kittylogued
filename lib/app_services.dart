import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/repository/library_repository.dart';
import 'package:kittylogued/services/app_settings.dart';
import 'package:kittylogued/services/auth_service.dart';
import 'package:kittylogued/services/backup_service.dart';
import 'package:kittylogued/services/batch_import_queue.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/services/friends_service.dart';
import 'package:kittylogued/services/saved_views_store.dart';

/// Everything the screens share. Built once in main() and handed to the
/// whole app through [AppScope]; a screen asks for what it needs with
/// `AppScope.of(context)` instead of receiving it through constructors.
class AppServices {
  final AppDatabase database;
  final LibraryRepository repository;
  final CoverCacheService coverCache;
  final AppSettings settings;
  final AuthService auth;
  final BackupService backup;
  final BatchImportQueue batchQueue;
  final SavedViewsStore savedViews;
  final FriendsService friends;

  /// Bump to ask the catalogue to focus its search box (Ctrl+F).
  final ValueNotifier<int> focusSearchRequests = ValueNotifier<int>(0);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AppServices({
    required this.database,
    required this.repository,
    required this.coverCache,
    required this.settings,
    required this.auth,
    required this.backup,
    required this.batchQueue,
    required this.savedViews,
    required this.friends,
  });
}

class AppScope extends InheritedWidget {
  final AppServices services;

  const AppScope({super.key, required this.services, required super.child});

  /// The shared services. Safe to call from initState too.
  static AppServices of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found above this widget');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
