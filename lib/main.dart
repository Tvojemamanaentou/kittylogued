import 'package:flutter/material.dart';
import 'package:kittylogued/app.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/services/cover_cache_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final coverCacheService = CoverCacheService();
  runApp(
    KittyloguedApp(database: database, coverCacheService: coverCacheService),
  );
}
