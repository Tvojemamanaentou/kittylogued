import 'package:kittylogued/database/app_database.dart';

class MonthBucket {
  final int year;
  final int month;
  int books = 0;
  int pages = 0;

  MonthBucket(this.year, this.month);
}

/// Numbers for the "Your reading" section on the home page.
class ReadingInsights {
  /// The last 12 months, oldest first.
  final List<MonthBucket> months;

  /// Ratings counted per half star: index 0 = 0.5 stars ... index 9 = 5 stars.
  final List<int> ratingHistogram;
  final int finishedThisYear;
  final int currentStreak;
  final int longestStreak;
  final int pagesThisWeek;

  const ReadingInsights({
    required this.months,
    required this.ratingHistogram,
    required this.finishedThisYear,
    required this.currentStreak,
    required this.longestStreak,
    required this.pagesThisWeek,
  });

  static ReadingInsights compute(
    List<Book> books,
    List<ReadingLog> logs,
    DateTime now,
  ) {
    final months = [
      for (var i = 0; i < 12; i++)
        () {
          final d = DateTime(now.year, now.month - 11 + i, 1);
          return MonthBucket(d.year, d.month);
        }(),
    ];
    MonthBucket? bucketFor(DateTime d) {
      for (final m in months) {
        if (m.year == d.year && m.month == d.month) return m;
      }
      return null;
    }

    final histogram = List<int>.filled(10, 0);
    final days = <DateTime>{};
    var finishedThisYear = 0;
    final liveIds = <int>{};

    for (final b in books) {
      liveIds.add(b.id);
      final rating = b.ratingHalfStars;
      if (rating != null && rating >= 1 && rating <= 10) {
        histogram[rating - 1]++;
      }
      final finished = b.finishedAt;
      if (b.readingStatus == 'read' && finished != null) {
        if (finished.year == now.year) finishedThisYear++;
        bucketFor(finished)?.books++;
        days.add(DateTime(finished.year, finished.month, finished.day));
      }
    }

    // Compare the last page reached on each date. A reduced page count replaces
    // that day's net progress instead of leaving an obsolete streak day behind.
    final byBook = <int, List<ReadingLog>>{};
    for (final l in logs) {
      if (!liveIds.contains(l.bookId)) continue;
      (byBook[l.bookId] ??= <ReadingLog>[]).add(l);
    }
    final dailyPageChanges = <DateTime, int>{};
    for (final entries in byBook.values) {
      final pageByDay = <DateTime, int>{};
      for (final entry in entries) {
        final date = DateTime(
          entry.loggedOn.year,
          entry.loggedOn.month,
          entry.loggedOn.day,
        );
        final current = pageByDay[date];
        if (current == null || entry.page > current) {
          pageByDay[date] = entry.page;
        }
      }
      final sortedDays = pageByDay.keys.toList()..sort();
      var previous = 0;
      for (final date in sortedDays) {
        final page = pageByDay[date]!;
        final change = page - previous;
        dailyPageChanges.update(
          date,
          (total) => total + change,
          ifAbsent: () => change,
        );
        if (change > 0) bucketFor(date)?.pages += change;
        previous = page;
      }
    }
    for (final entry in dailyPageChanges.entries) {
      if (entry.value > 0) days.add(entry.key);
    }
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = DateTime(today.year, today.month, today.day - 6);
    final pagesThisWeek = dailyPageChanges.entries
        .where(
          (entry) =>
              !entry.key.isBefore(weekStart) &&
              !entry.key.isAfter(today) &&
              entry.value > 0,
        )
        .fold<int>(0, (total, entry) => total + entry.value);

    // Streaks of consecutive days with any reading activity.
    var current = 0;
    var day = DateTime(now.year, now.month, now.day);
    if (!days.contains(day)) day = DateTime(day.year, day.month, day.day - 1);
    while (days.contains(day)) {
      current++;
      day = DateTime(day.year, day.month, day.day - 1);
    }

    var longest = 0;
    var run = 0;
    DateTime? last;
    final sorted = days.toList()..sort();
    for (final d in sorted) {
      if (last != null && DateTime(last.year, last.month, last.day + 1) == d) {
        run++;
      } else {
        run = 1;
      }
      if (run > longest) longest = run;
      last = d;
    }

    return ReadingInsights(
      months: months,
      ratingHistogram: histogram,
      finishedThisYear: finishedThisYear,
      currentStreak: current,
      longestStreak: longest,
      pagesThisWeek: pagesThisWeek,
    );
  }
}
