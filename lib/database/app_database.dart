import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:kittylogued/database/db_files.dart';
import 'package:kittylogued/models/book_draft.dart';
import 'package:kittylogued/utils/uuid.dart';

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

  // Sync identity and ownership (the account that owns this book)
  TextColumn get uid => text().nullable()();
  IntColumn get ownerId => integer().nullable().references(Users, #id)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // Soft delete: set when the book is moved to "Recently deleted".
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Public opinion: rating in half stars (0-10, null = not rated) + comment
  IntColumn get ratingHalfStars => integer().nullable()();
  TextColumn get reviewText => text().nullable()();

  // Reading progress
  IntColumn get currentPage => integer().withDefault(const Constant(0))();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();

  // Audit timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// People: the main account (isMe) and, later, friends.
/// Every book belongs to one user.
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text()();
  TextColumn get username => text().nullable()();
  TextColumn get displayName => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  BoolColumn get isMe => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Dated reading-progress entries; they can be backdated.
class ReadingLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get loggedOn => dateTime()();
  IntColumn get page => integer()();
  TextColumn get note => text().nullable()();
}

/// Lending and borrowing.
/// - direction 'lent': one of my books is with someone else (bookId is set).
/// - direction 'borrowed': I have someone else's book (title/author are set,
///   because it is not in my library).
/// Status: 'requested' (asked a friend, waiting), 'active', 'returned'.
class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text()();
  TextColumn get direction => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get bookId =>
      integer().nullable().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().nullable()();
  TextColumn get author => text().nullable()();

  /// Set when the other person is a friend with an account (later).
  IntColumn get personUserId => integer().nullable()();

  /// Friend's username or a nickname for someone without an account.
  TextColumn get personName => text()();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get returnedAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
}

/// Cached ISBN lookup results, so repeated lookups do not hit the network.
class LookupCacheEntries extends Table {
  TextColumn get isbn => text()();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {isbn};
}

/// Books scanned/typed in batch mode that are still waiting for review.
class BatchQueueEntries extends Table {
  TextColumn get uid => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uid};
}

/// Personal, free-form tags (shared across books).
/// Public tags are visible to friends, private ones are not.
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
}

/// Join table linking books and tags (many-to-many).
class BookTags extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {bookId, tagId};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Safety copy before any upgrade touches the file.
    await snapshotBeforeUpgrade(kSchemaVersion);
    final file = await databaseFile();
    return NativeDatabase.createInBackground(file);
  });
}

/// Current schema version. Raise it with every schema change.
const int kSchemaVersion = 7;

@DriftDatabase(
  tables: [
    Books,
    Tags,
    BookTags,
    Users,
    ReadingLogs,
    LookupCacheEntries,
    BatchQueueEntries,
    Loans,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => kSchemaVersion;

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
      if (from < 4) {
        await m.addColumn(books, books.currentPage);
        await m.addColumn(books, books.startedAt);
        await m.addColumn(books, books.finishedAt);
        await m.createTable(tags);
        await m.createTable(bookTags);
        // Books already marked as finished count as fully read.
        await customStatement(
          "UPDATE books SET current_page = COALESCE(page_count, 0) "
          "WHERE reading_status = 'read'",
        );
      }
      if (from < 5) {
        await m.createTable(users);
        await m.createTable(readingLogs);
        await m.addColumn(books, books.uid);
        await m.addColumn(books, books.ownerId);
        await m.addColumn(books, books.updatedAt);
        await m.addColumn(books, books.ratingHalfStars);
        await m.addColumn(books, books.reviewText);
        await m.addColumn(tags, tags.isPublic);

        // Every existing book belongs to the main account.
        final me = await ensureMeUser();
        await customStatement('UPDATE books SET owner_id = ?', [me.id]);
        final existing = await select(books).get();
        for (final b in existing) {
          await (update(books)..where((t) => t.id.equals(b.id))).write(
            BooksCompanion(uid: Value(newUuid())),
          );
        }
        // Old 1-5 rating becomes half stars (0-10).
        await customStatement(
          'UPDATE books SET rating_half_stars = CAST(ROUND(personal_rating * 2) AS INTEGER) '
          'WHERE personal_rating IS NOT NULL',
        );
      }
      if (from < 6) {
        await m.addColumn(books, books.deletedAt);
        await m.createTable(lookupCacheEntries);
        await m.createTable(batchQueueEntries);
      }
      if (from < 7) {
        await m.createTable(loans);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await markSchemaVersion(kSchemaVersion);
    },
  );

  // ---------------------------------------------------------------------
  // Tags
  // ---------------------------------------------------------------------

  /// All tags, alphabetically.
  Stream<List<Tag>> watchAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  /// Map of book id -> its tags, kept up to date.
  Stream<Map<int, List<Tag>>> watchTagsByBook() {
    final query = select(bookTags).join([
      innerJoin(tags, tags.id.equalsExp(bookTags.tagId)),
      innerJoin(books, books.id.equalsExp(bookTags.bookId)),
    ])..where(books.deletedAt.isNull());
    return query.watch().map((rows) {
      final result = <int, List<Tag>>{};
      for (final row in rows) {
        final link = row.readTable(bookTags);
        final tag = row.readTable(tags);
        (result[link.bookId] ??= <Tag>[]).add(tag);
      }
      for (final list in result.values) {
        list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      }
      return result;
    });
  }

  /// Tags currently attached to one book (with their visibility).
  Future<List<TagDraft>> tagsForBook(int bookId) async {
    final query = select(
      bookTags,
    ).join([innerJoin(tags, tags.id.equalsExp(bookTags.tagId))])
      ..where(bookTags.bookId.equals(bookId));
    final rows = await query.get();
    final result = rows
        .map((r) {
          final t = r.readTable(tags);
          return TagDraft(t.name, isPublic: t.isPublic);
        })
        .toList();
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  /// Replaces the tags of a book, creating missing tags. A tag that already
  /// exists takes the visibility given here.
  Future<void> setBookTags(int bookId, List<TagDraft> drafts) async {
    await transaction(() async {
      final cleaned = <TagDraft>[];
      for (final raw in drafts) {
        final name = raw.name.trim();
        if (name.isEmpty) continue;
        if (cleaned.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
          continue;
        }
        cleaned.add(raw.copyWith(name: name));
      }

      final existing = await select(tags).get();
      final ids = <int>[];
      for (final draft in cleaned) {
        final match = existing.where(
          (t) => t.name.toLowerCase() == draft.name.toLowerCase(),
        );
        if (match.isNotEmpty) {
          final tag = match.first;
          if (tag.isPublic != draft.isPublic) {
            await (update(tags)..where((t) => t.id.equals(tag.id))).write(
              TagsCompanion(isPublic: Value(draft.isPublic)),
            );
          }
          ids.add(tag.id);
        } else {
          ids.add(
            await into(tags).insert(
              TagsCompanion.insert(
                name: draft.name,
                isPublic: Value(draft.isPublic),
              ),
            ),
          );
        }
      }

      await (delete(bookTags)..where((t) => t.bookId.equals(bookId))).go();
      for (final id in ids) {
        await into(
          bookTags,
        ).insert(BookTagsCompanion.insert(bookId: bookId, tagId: id));
      }
    });
    await removeUnusedTags();
  }

  /// Deletes tags that no book uses any more.
  Future<void> removeUnusedTags() {
    return customUpdate(
      'DELETE FROM tags WHERE id NOT IN (SELECT tag_id FROM book_tags)',
      updates: {tags},
      updateKind: UpdateKind.delete,
    );
  }

  // ---------------------------------------------------------------------
  // Books (live and deleted)
  // ---------------------------------------------------------------------

  /// Books that are not in the recycle bin.
  Stream<List<Book>> watchLiveBooks() {
    return (select(books)..where((b) => b.deletedAt.isNull())).watch();
  }

  /// Books in "Recently deleted", newest deletion first.
  Stream<List<Book>> watchDeletedBooks() {
    return (select(books)
          ..where((b) => b.deletedAt.isNotNull())
          ..orderBy([(b) => OrderingTerm.desc(b.deletedAt)]))
        .watch();
  }

  /// One book (live or deleted), kept up to date.
  Stream<Book?> watchBook(int id) {
    return (select(books)..where((b) => b.id.equals(id))).watchSingleOrNull();
  }

  /// All loans with the lent book attached (when there is one), newest first.
  Stream<List<LoanEntry>> watchLoanEntries() {
    final query = select(loans).join([
      leftOuterJoin(books, books.id.equalsExp(loans.bookId)),
    ])..orderBy([OrderingTerm.desc(loans.startedAt)]);
    return query.watch().map(
      (rows) => rows
          .map((r) => LoanEntry(r.readTable(loans), r.readTableOrNull(books)))
          .toList(),
    );
  }

  /// Writes a consistent copy of the whole database to [path].
  Future<void> vacuumInto(String path) {
    return customStatement('VACUUM INTO ?', [path]);
  }

  // ---------------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------------

  /// The main account's user row, created on first use.
  Future<User> ensureMeUser() async {
    final existing = await (select(users)..where((u) => u.isMe.equals(true)))
        .getSingleOrNull();
    if (existing != null) return existing;
    final id = await into(users).insert(
      UsersCompanion.insert(uid: newUuid(), isMe: const Value(true)),
    );
    return (select(users)..where((u) => u.id.equals(id))).getSingle();
  }

  // ---------------------------------------------------------------------
  // Reading log
  // ---------------------------------------------------------------------

  Stream<List<ReadingLog>> watchAllReadingLogs() => select(readingLogs).watch();

  Future<void> addReadingLog(int bookId, DateTime date, int page) async {
    await into(readingLogs).insert(
      ReadingLogsCompanion.insert(bookId: bookId, loggedOn: date, page: page),
    );
  }

  Future<List<ReadingLogDraft>> logsForBook(int bookId) async {
    final rows = await (select(readingLogs)
          ..where((l) => l.bookId.equals(bookId))
          ..orderBy([(l) => OrderingTerm.asc(l.loggedOn)]))
        .get();
    return rows.map((r) => ReadingLogDraft(r.loggedOn, r.page)).toList();
  }

  /// Replaces all progress entries of a book.
  Future<void> setReadingLogs(int bookId, List<ReadingLogDraft> drafts) async {
    await transaction(() async {
      await (delete(readingLogs)..where((l) => l.bookId.equals(bookId))).go();
      for (final d in drafts) {
        await into(readingLogs).insert(
          ReadingLogsCompanion.insert(
            bookId: bookId,
            loggedOn: d.date,
            page: d.page,
          ),
        );
      }
    });
  }
}

/// A loan together with the book it is about (when it is one of mine).
class LoanEntry {
  final Loan loan;
  final Book? book;

  const LoanEntry(this.loan, this.book);
}
