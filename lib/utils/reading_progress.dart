/// Pure helpers for reading progress; no Flutter or database dependencies.
class ReadingProgress {
  /// Status implied by the current page: 0 = unread, last page = read.
  static String statusForPage(int page, int? total) {
    if (page <= 0) return 'unread';
    if (total != null && total > 0 && page >= total) return 'read';
    return 'reading';
  }

  /// Keeps [page] within 0..[total] (when the total is known).
  static int clampPage(int page, int? total) {
    if (page < 0) return 0;
    if (total != null && total > 0 && page > total) return total;
    return page;
  }

  /// Progress from 0.0 to 1.0.
  static double fraction(String status, int page, int? total) {
    if (status == 'read') return 1.0;
    if (total == null || total <= 0) return 0.0;
    return (page / total).clamp(0.0, 1.0);
  }

  /// Colour step for the progress bar:
  /// 0 = to read (neutral), 1 = just started (red), 2 = orange, 3 = yellow,
  /// 4 = finished (green).
  static int stepFor(String status, double fraction) {
    if (status == 'read') return 4;
    if (status == 'unread' || fraction <= 0) return 0;
    if (fraction < 1 / 3) return 1;
    if (fraction < 2 / 3) return 2;
    return 3;
  }

  /// Start/finish dates that go with [status].
  ///
  /// Existing dates are kept; a missing start date is set when reading
  /// begins, and a finish date when the book is marked as read.
  static ({DateTime? startedAt, DateTime? finishedAt}) datesFor({
    required String status,
    DateTime? startedAt,
    DateTime? finishedAt,
    DateTime? now,
  }) {
    final stamp = now ?? DateTime.now();
    if (status == 'unread') return (startedAt: null, finishedAt: null);
    final started = startedAt ?? stamp;
    if (status == 'read') {
      return (startedAt: started, finishedAt: finishedAt ?? stamp);
    }
    return (startedAt: started, finishedAt: null);
  }
}
