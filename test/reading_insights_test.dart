import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/models/book_draft.dart';
import 'package:kittylogued/repositories/library_repository.dart';
import 'package:kittylogued/utils/reading_insights.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _TestPathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _TestPathProvider();

  late AppDatabase database;
  late LibraryRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LibraryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'a negative daily page change no longer counts toward the streak',
    () async {
      final yesterday = DateTime(2025, 1, 9);
      final today = DateTime(2025, 1, 10);
      final bookId = await repository.addBook(
        BookDraft(
          title: 'A Test Book',
          author: 'A. Reader',
          logs: [ReadingLogDraft(yesterday, 20), ReadingLogDraft(today, 10)],
        ),
      );
      final books = await database.watchLiveBooks().first;
      final logs = await database.watchAllReadingLogs().first;

      final insights = ReadingInsights.compute(
        books.where((book) => book.id == bookId).toList(),
        logs,
        today,
      );

      expect(insights.currentStreak, 1);
      expect(insights.pagesThisWeek, 20);
    },
  );
}
