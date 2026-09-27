import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get author => text().withLength(min: 1, max: 255)();
  TextColumn get isbn => text().nullable()();
  TextColumn get shelfLocation => text().nullable()();
  TextColumn get readingStatus => text().withDefault(const Constant('unread'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<Book>> watchAllBooks() {
    return (select(books)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<int> insertBook({
    required String title,
    required String author,
    String? isbn,
    String? shelfLocation,
  }) {
    return into(books).insert(
      BooksCompanion.insert(
        title: title,
        author: author,
        isbn: Value(isbn),
        shelfLocation: Value(shelfLocation),
      ),
    );
  }

  Future<int> deleteBook(int id) {
    return (delete(books)..where((tbl) => tbl.id.equals(id))).go();
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'kittylogued.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

