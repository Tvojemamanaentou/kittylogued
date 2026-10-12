import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kittylogued/app.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/database/db_files.dart';
import 'package:kittylogued/repository/library_repository.dart';
import 'package:kittylogued/services/app_settings.dart';
import 'package:kittylogued/services/auth_service.dart';
import 'package:kittylogued/services/backup_service.dart';
import 'package:kittylogued/services/batch_import_queue.dart';
import 'package:kittylogued/services/batch_queue_store.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';
import 'package:kittylogued/services/lookup_cache_store.dart';
import 'package:kittylogued/services/saved_views_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Finish a backup restore that was scheduled before the last shutdown.
  await applyPendingRestore();

  final database = AppDatabase();
  final services = AppServices(
    database: database,
    repository: LibraryRepository(database),
    coverCache: CoverCacheService(),
    settings: await AppSettings.load(),
    auth: await AuthService.load(),
    backup: BackupService(database),
    batchQueue: BatchImportQueue(store: BatchQueueStore(database)),
    savedViews: await SavedViewsStore.load(),
  );
  IsbnLookupService.cache = LookupCacheStore(database);

  runApp(KittyloguedApp(services: services));

  // Background chores after the first frame.
  unawaited(services.batchQueue.restore());
  unawaited(services.repository.purgeExpired());
  unawaited(services.backup.snapshotIfDue());
}
