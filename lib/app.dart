import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/pages/main_shell.dart';
import 'package:kittylogued/services/cover_cache_service.dart';

class KittyloguedApp extends StatelessWidget {
  final AppDatabase database;
  final CoverCacheService coverCacheService;

  const KittyloguedApp({
    super.key,
    required this.database,
    required this.coverCacheService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kittylogued',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: MainShell(
        database: database,
        coverCacheService: coverCacheService,
      ),
    );
  }
}
