import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// The central Books table storing library holdings and bibliographic metadata.
class Books extends Table {
  // Primary database key
  IntColumn get id => integer().autoIncrement()();

  // Immutable composite identifier
  TextColumn get internalId => text().nullable()();

  // Core metadata
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get originalTitle => text().nullable()();
  TextColumn get isbn => text().nullable()();

  // Physical library placement & call number
  TextColumn get shelfLocation => text().nullable()();
  TextColumn get signatura => text().nullable()();

  // Publication details
  TextColumn get publisher => text().nullable()();
  IntColumn get publicationYear => integer().nullable()();
  TextColumn get language => text().withDefault(const Constant('cze'))();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get bindingType =>
      text().nullable()(); // 'paperback', 'hardcover', 'special'
  TextColumn get secondaryContributors =>
      text().nullable()(); // Translators, editors

  // Personal cataloging & condition
  TextColumn get readingStatus => text().withDefault(
    const Constant('unread'),
  )(); // 'unread', 'reading', 'read'
  RealColumn get personalRating => real().nullable()(); // 1.0 to 5.0
  TextColumn get privateNotes => text().nullable()();
  TextColumn get physicalCondition => text().nullable()();
  BoolColumn get isWishlist => boolean().withDefault(const Constant(false))();

  // Artwork & description
  TextColumn get coverUrl => text().nullable()();
  TextColumn get synopsis => text().nullable()();

  // Audit timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kittylogued.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(books, books.coverUrl);
      }
      if (from < 3) {
        await m.addColumn(books, books.internalId);
        await m.addColumn(books, books.originalTitle);
        await m.addColumn(books, books.signatura);
        await m.addColumn(books, books.publisher);
        await m.addColumn(books, books.publicationYear);
        await m.addColumn(books, books.language);
        await m.addColumn(books, books.pageCount);
        await m.addColumn(books, books.bindingType);
        await m.addColumn(books, books.secondaryContributors);
        await m.addColumn(books, books.personalRating);
        await m.addColumn(books, books.privateNotes);
        await m.addColumn(books, books.physicalCondition);
        await m.addColumn(books, books.isWishlist);
        await m.addColumn(books, books.synopsis);
      }
    },
  );
}
