import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kittylogued/app.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/database/db_files.dart';
import 'package:kittylogued/repositories/library_repository.dart';
import 'package:kittylogued/services/app_settings.dart';
import 'package:kittylogued/services/auth_service.dart';
import 'package:kittylogued/services/backup_service.dart';
import 'package:kittylogued/services/batch_import_queue.dart';
import 'package:kittylogued/services/batch_queue_store.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/services/friends_service.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';
import 'package:kittylogued/services/lookup_cache_store.dart';
import 'package:kittylogued/services/saved_views_store.dart';

/// Application bootstrap. The goal is intentionally simple: initialize persistent
/// dependencies, build the shared service graph, and then hand control to the UI.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // If the previous session requested a restore, complete it before the user
    // sees any app state. This keeps the app startup deterministic.
    await applyPendingRestore();

    // Build the application service graph once and share it through AppScope.
    final database = AppDatabase();
    final settings = await AppSettings.load();
    final auth = await AuthService.load();
    final savedViews = await SavedViewsStore.load();

    final services = AppServices(
      database: database,
      repository: LibraryRepository(database),
      coverCache: CoverCacheService(),
      settings: settings,
      auth: auth,
      backup: BackupService(database),
      batchQueue: BatchImportQueue(store: BatchQueueStore(database)),
      savedViews: savedViews,
      friends: FriendsService(),
    );

    // The cache is global to the app and is shared by lookup flows.
    IsbnLookupService.cache = LookupCacheStore(database);

    runApp(KittyloguedApp(services: services));

    // These tasks are safe to continue in the background after the first frame.
    unawaited(services.batchQueue.restore());
    unawaited(services.repository.purgeExpired());
    unawaited(services.backup.snapshotIfDue());
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Kittylogued bootstrap',
        context: ErrorDescription('Fatal app initialization failed.'),
      ),
    );
    rethrow;
  }
}
