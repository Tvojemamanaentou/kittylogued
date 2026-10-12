import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/utils/reading_progress.dart';

void main() {
  group('statusForPage', () {
    test('0 is unread, last page is read, otherwise reading', () {
      expect(ReadingProgress.statusForPage(0, 300), 'unread');
      expect(ReadingProgress.statusForPage(120, 300), 'reading');
      expect(ReadingProgress.statusForPage(300, 300), 'read');
    });

    test('without a page count any progress is reading', () {
      expect(ReadingProgress.statusForPage(50, null), 'reading');
    });
  });

  test('clampPage keeps the page inside the book', () {
    expect(ReadingProgress.clampPage(-5, 300), 0);
    expect(ReadingProgress.clampPage(999, 300), 300);
    expect(ReadingProgress.clampPage(42, 300), 42);
  });

  test('stepFor gives five colour steps', () {
    expect(ReadingProgress.stepFor('unread', 0), 0);
    expect(ReadingProgress.stepFor('reading', 0.1), 1);
    expect(ReadingProgress.stepFor('reading', 0.5), 2);
    expect(ReadingProgress.stepFor('reading', 0.9), 3);
    expect(ReadingProgress.stepFor('read', 1), 4);
  });

  group('datesFor', () {
    final day = DateTime(2026, 3, 1);

    test('starting sets the start date, using the given day', () {
      final d = ReadingProgress.datesFor(status: 'reading', now: day);
      expect(d.startedAt, day);
      expect(d.finishedAt, isNull);
    });

    test('finishing keeps an earlier start date', () {
      final started = DateTime(2026, 2, 1);
      final d = ReadingProgress.datesFor(
        status: 'read',
        startedAt: started,
        now: day,
      );
      expect(d.startedAt, started);
      expect(d.finishedAt, day);
    });

    test('unread clears both dates', () {
      final d = ReadingProgress.datesFor(
        status: 'unread',
        startedAt: day,
        finishedAt: day,
      );
      expect(d.startedAt, isNull);
      expect(d.finishedAt, isNull);
    });
  });
}
