import 'package:kittylogued/database/app_database.dart';

class PeriodStats {
  /// Books finished in the period.
  final int books;

  /// Total pages of those finished books.
  final int pages;

  /// Pages logged as read in the period (from dated progress entries).
  final int pagesLogged;

  const PeriodStats(this.books, this.pages, this.pagesLogged);
}

/// Numbers shown in the library overview on the personal page.
class LibraryStats {
  final int total;
  final int read;
  final int reading;
  final int unread;
  final PeriodStats week;
  final PeriodStats month;
  final PeriodStats year;
  final PeriodStats overall;

  /// Average of all ratings in stars (0-5), null when nothing is rated.
  final double? averageRating;
  final int ratedCount;

  /// Null until at least one finished book has start/finish dates and pages.
  final double? pagesPerDay;
  final double? daysPerBook;

  const LibraryStats({
    required this.total,
    required this.read,
    required this.reading,
    required this.unread,
    required this.week,
    required this.month,
    required this.year,
    required this.overall,
    required this.averageRating,
    required this.ratedCount,
    required this.pagesPerDay,
    required this.daysPerBook,
  });

  static LibraryStats compute(
    List<Book> books,
    List<ReadingLog> logs,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1)); // Monday
    final monthStart = DateTime(now.year, now.month, 1);
    final yearStart = DateTime(now.year, 1, 1);

    int read = 0, reading = 0, unread = 0;
    // [books, pages, pagesLogged] per period
    final period = {
      'week': [0, 0, 0],
      'month': [0, 0, 0],
      'year': [0, 0, 0],
      'overall': [0, 0, 0],
    };

    void addBook(String key, int pages) {
      period[key]![0] += 1;
      period[key]![1] += pages;
    }

    double speedPages = 0;
    double speedDays = 0;
    int speedBooks = 0;
    int ratingSum = 0;
    int ratedCount = 0;

    for (final b in books) {
      final rating = b.ratingHalfStars;
      if (rating != null) {
        ratingSum += rating;
        ratedCount++;
      }

      switch (b.readingStatus) {
        case 'read':
          read++;
          break;
        case 'reading':
          reading++;
          break;
        default:
          unread++;
      }
      if (b.readingStatus != 'read') continue;

      final pages = b.pageCount ?? 0;
      addBook('overall', pages);

      final finished = b.finishedAt;
      if (finished != null) {
        if (!finished.isBefore(weekStart)) addBook('week', pages);
        if (!finished.isBefore(monthStart)) addBook('month', pages);
        if (!finished.isBefore(yearStart)) addBook('year', pages);
      }

      final started = b.startedAt;
      if (started != null && finished != null && pages > 0) {
        final days = finished.difference(started).inHours / 24.0;
        speedPages += pages;
        speedDays += days < 1 ? 1 : days;
        speedBooks++;
      }
    }

    // Pages read per day, from the dated progress entries: each entry counts
    // the pages gained since the previous (earlier) entry of the same book.
    final byBook = <int, List<ReadingLog>>{};
    final liveIds = books.map((b) => b.id).toSet();
    for (final l in logs) {
      if (!liveIds.contains(l.bookId)) continue;
      (byBook[l.bookId] ??= <ReadingLog>[]).add(l);
    }
    for (final entries in byBook.values) {
      entries.sort((a, b) {
        final c = a.loggedOn.compareTo(b.loggedOn);
        return c != 0 ? c : a.page.compareTo(b.page);
      });
      var previous = 0;
      for (final e in entries) {
        if (e.page <= previous) continue;
        final gained = e.page - previous;
        previous = e.page;
        period['overall']![2] += gained;
        if (!e.loggedOn.isBefore(weekStart)) period['week']![2] += gained;
        if (!e.loggedOn.isBefore(monthStart)) period['month']![2] += gained;
        if (!e.loggedOn.isBefore(yearStart)) period['year']![2] += gained;
      }
    }

    PeriodStats ps(String k) =>
        PeriodStats(period[k]![0], period[k]![1], period[k]![2]);

    return LibraryStats(
      total: books.length,
      read: read,
      reading: reading,
      unread: unread,
      week: ps('week'),
      month: ps('month'),
      year: ps('year'),
      overall: ps('overall'),
      averageRating: ratedCount > 0 ? ratingSum / ratedCount / 2 : null,
      ratedCount: ratedCount,
      pagesPerDay: speedBooks > 0 ? speedPages / speedDays : null,
      daysPerBook: speedBooks > 0 ? speedDays / speedBooks : null,
    );
  }
}
