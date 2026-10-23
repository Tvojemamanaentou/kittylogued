import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/models/book_draft.dart';
import 'package:kittylogued/repositories/library_repository.dart';
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
    'adding a book persists its tags and reading history together',
    () async {
      final id = await repository.addBook(
        BookDraft(
          title: 'A Test Book',
          author: 'A. Reader',
          tags: [TagDraft('Favorites')],
          logs: [ReadingLogDraft(DateTime.utc(2026, 1, 2), 5)],
        ),
      );

      final book = await (database.select(
        database.books,
      )..where((row) => row.id.equals(id))).getSingle();
      final tags = await database.tagsForBook(id);
      final logs = await database.logsForBook(id);

      expect(book.title, 'A Test Book');
      expect(book.ownerId, isNotNull);
      expect(tags.map((tag) => tag.name), ['Favorites']);
      expect(logs.single.page, 5);
    },
  );

  test(
    'updating a missing book reports an error instead of succeeding silently',
    () {
      return expectLater(
        repository.updateBook(
          999,
          const BookDraft(title: 'Missing', author: 'Nobody'),
        ),
        throwsA(isA<StateError>()),
      );
    },
  );

  test('findByIsbn ignores punctuation and deleted books', () async {
    final id = await repository.addBook(
      const BookDraft(
        title: 'ISBN Book',
        author: 'A. Reader',
        isbn: '978-80-257-0000-0',
      ),
    );

    expect(await repository.findByIsbn('9788025700000'), isNotNull);
    await repository.softDelete(id);
    expect(await repository.findByIsbn('9788025700000'), isNull);
  });
}
