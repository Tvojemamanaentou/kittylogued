import 'package:drift/drift.dart' as drift;
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/models/book_draft.dart';
import 'package:kittylogued/utils/book_identifier.dart';
import 'package:kittylogued/utils/reading_progress.dart';
import 'package:kittylogued/utils/uuid.dart';

/// The one place that turns a [BookDraft] into database rows (and back).
/// Screens should save and delete books through this class so that ids,
/// owner and timestamps are always set the same way.
class LibraryRepository {
  final AppDatabase db;

  LibraryRepository(this.db);

  /// Adds a book to the main account's library. Returns its row id.
  Future<int> addBook(BookDraft d) async {
    final me = await db.ensureMeUser();
    final id = await db
        .into(db.books)
        .insert(
          BooksCompanion.insert(
            title: d.title,
            author: d.author,
            internalId: drift.Value(BookIdentifier.generate(title: d.title)),
            uid: drift.Value(newUuid()),
            ownerId: drift.Value(me.id),
            updatedAt: drift.Value(DateTime.now()),
            isbn: drift.Value(d.isbn),
            publisher: drift.Value(d.publisher),
            publicationYear: drift.Value(d.publicationYear),
            pageCount: drift.Value(d.pageCount),
            bindingType: drift.Value(d.bindingType),
            secondaryContributors: drift.Value(d.secondaryContributors),
            coverUrl: drift.Value(d.coverUrl),
            synopsis: drift.Value(d.synopsis),
            shelfLocation: drift.Value(d.shelfLocation),
            signatura: drift.Value(d.signatura),
            readingStatus: drift.Value(d.readingStatus),
            currentPage: drift.Value(d.currentPage),
            startedAt: drift.Value(d.startedAt),
            finishedAt: drift.Value(d.finishedAt),
            ratingHalfStars: drift.Value(d.ratingHalfStars),
            reviewText: drift.Value(d.reviewText),
            privateNotes: drift.Value(d.privateNotes),
          ),
        );
    await db.setBookTags(id, d.tags);
    await db.setReadingLogs(id, d.logs);
    return id;
  }

  /// Updates an existing book. Its internal id and uid never change.
  Future<void> updateBook(int id, BookDraft d) async {
    await (db.update(db.books)..where((t) => t.id.equals(id))).write(
      BooksCompanion(
        title: drift.Value(d.title),
        author: drift.Value(d.author),
        updatedAt: drift.Value(DateTime.now()),
        isbn: drift.Value(d.isbn),
        publisher: drift.Value(d.publisher),
        publicationYear: drift.Value(d.publicationYear),
        pageCount: drift.Value(d.pageCount),
        bindingType: drift.Value(d.bindingType),
        secondaryContributors: drift.Value(d.secondaryContributors),
        coverUrl: drift.Value(d.coverUrl),
        synopsis: drift.Value(d.synopsis),
        shelfLocation: drift.Value(d.shelfLocation),
        signatura: drift.Value(d.signatura),
        readingStatus: drift.Value(d.readingStatus),
        currentPage: drift.Value(d.currentPage),
        startedAt: drift.Value(d.startedAt),
        finishedAt: drift.Value(d.finishedAt),
        ratingHalfStars: drift.Value(d.ratingHalfStars),
        reviewText: drift.Value(d.reviewText),
        privateNotes: drift.Value(d.privateNotes),
      ),
    );
    await db.setBookTags(id, d.tags);
    await db.setReadingLogs(id, d.logs);
  }

  // -------------------------------------------------------------------
  // Lending and borrowing
  // -------------------------------------------------------------------

  /// Lends one of my books to a friend or to someone without an account.
  Future<int> lendBook(
    Book book, {
    required String personName,
    int? personUserId,
    DateTime? dueAt,
  }) {
    return db
        .into(db.loans)
        .insert(
          LoansCompanion.insert(
            uid: newUuid(),
            direction: 'lent',
            bookId: drift.Value(book.id),
            personName: personName.trim(),
            personUserId: drift.Value(personUserId),
            dueAt: drift.Value(dueAt),
          ),
        );
  }

  /// Records a book I borrowed from someone without an account.
  Future<int> borrowFromPerson({
    required String personName,
    int? personUserId,
    required String title,
    String? author,
    DateTime? dueAt,
  }) {
    return db
        .into(db.loans)
        .insert(
          LoansCompanion.insert(
            uid: newUuid(),
            direction: 'borrowed',
            title: drift.Value(title.trim()),
            author: drift.Value(author?.trim()),
            personName: personName.trim(),
            personUserId: drift.Value(personUserId),
            dueAt: drift.Value(dueAt),
          ),
        );
  }

  /// Saves a request to borrow a book from a friend.
  /// TODO: send it to the friend (notification) once friends are connected;
  /// accepting it should then switch the friend's book to "lent".
  Future<int> requestBorrow({
    required String friendName,
    int? friendUserId,
    required String title,
    String? author,
  }) {
    return db
        .into(db.loans)
        .insert(
          LoansCompanion.insert(
            uid: newUuid(),
            direction: 'borrowed',
            status: const drift.Value('requested'),
            title: drift.Value(title.trim()),
            author: drift.Value(author?.trim()),
            personName: friendName.trim(),
            personUserId: drift.Value(friendUserId),
          ),
        );
  }

  Future<void> returnLoan(int id) async {
    await (db.update(db.loans)..where((l) => l.id.equals(id))).write(
      LoansCompanion(
        status: const drift.Value('returned'),
        returnedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteLoan(int id) async {
    await (db.delete(db.loans)..where((l) => l.id.equals(id))).go();
  }

  // -------------------------------------------------------------------
  // Recycle bin: books are hidden first, removed for good after 30 days.
  // -------------------------------------------------------------------

  static const int binKeepDays = 30;
  static const Duration binKeepTime = Duration(days: binKeepDays);

  /// Moves a book to "Recently deleted".
  Future<void> softDelete(int id) async {
    final now = DateTime.now();
    await (db.update(db.books)..where((t) => t.id.equals(id))).write(
      BooksCompanion(
        deletedAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );
  }

  /// Brings a book back from "Recently deleted".
  Future<void> restore(int id) async {
    await (db.update(db.books)..where((t) => t.id.equals(id))).write(
      BooksCompanion(
        deletedAt: const drift.Value(null),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  /// Removes one book for good.
  Future<void> deleteForever(int id) async {
    await (db.delete(db.books)..where((t) => t.id.equals(id))).go();
    await db.removeUnusedTags();
  }

  /// Removes everything in the bin for good.
  Future<void> emptyBin() async {
    await (db.delete(db.books)..where((t) => t.deletedAt.isNotNull())).go();
    await db.removeUnusedTags();
  }

  /// Removes books that have been in the bin longer than [binKeepTime].
  Future<void> purgeExpired() async {
    final cutoff = DateTime.now().subtract(binKeepTime);
    await (db.delete(db.books)
          ..where((t) => t.deletedAt.isSmallerThanValue(cutoff)))
        .go();
    await db.removeUnusedTags();
  }

  // -------------------------------------------------------------------
  // Quick actions (swipe, long-press sheet)
  // -------------------------------------------------------------------

  /// Marks a book as finished (jumps to the last page when it is known).
  Future<void> markRead(Book book) async {
    final total = book.pageCount;
    final hasTotal = total != null && total > 0;
    final page = hasTotal ? total : book.currentPage;
    final dates = ReadingProgress.datesFor(
      status: 'read',
      startedAt: book.startedAt,
      finishedAt: book.finishedAt,
    );
    await (db.update(db.books)..where((t) => t.id.equals(book.id))).write(
      BooksCompanion(
        readingStatus: const drift.Value('read'),
        currentPage: drift.Value(page),
        startedAt: drift.Value(dates.startedAt),
        finishedAt: drift.Value(dates.finishedAt),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
    if (hasTotal && page != book.currentPage) {
      await db.addReadingLog(book.id, DateTime.now(), page);
    }
  }

  /// Sets the page (and optionally the rating) in one go and logs the page.
  Future<void> quickUpdate(
    Book book, {
    required int page,
    int? rating,
    bool updateRating = false,
  }) async {
    final total = book.pageCount;
    final clamped = ReadingProgress.clampPage(page, total);
    final status = ReadingProgress.statusForPage(clamped, total);
    final dates = ReadingProgress.datesFor(
      status: status,
      startedAt: book.startedAt,
      finishedAt: book.finishedAt,
    );
    await (db.update(db.books)..where((t) => t.id.equals(book.id))).write(
      BooksCompanion(
        readingStatus: drift.Value(status),
        currentPage: drift.Value(clamped),
        startedAt: drift.Value(dates.startedAt),
        finishedAt: drift.Value(dates.finishedAt),
        ratingHalfStars: updateRating
            ? drift.Value(rating)
            : const drift.Value.absent(),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
    if (clamped > 0 && clamped != book.currentPage) {
      await db.addReadingLog(book.id, DateTime.now(), clamped);
    }
  }
}
