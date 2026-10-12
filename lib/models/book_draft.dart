/// A tag as edited in the UI. Public tags are visible to friends,
/// private tags never leave this device.
class TagDraft {
  final String name;
  final bool isPublic;

  const TagDraft(this.name, {this.isPublic = false});

  TagDraft copyWith({String? name, bool? isPublic}) =>
      TagDraft(name ?? this.name, isPublic: isPublic ?? this.isPublic);
}

/// One dated reading-progress entry (page reached on a given day).
class ReadingLogDraft {
  final DateTime date;
  final int page;

  const ReadingLogDraft(this.date, this.page);
}

/// Everything the user can enter about one book. The form builds one of
/// these; the repository turns it into database rows.
class BookDraft {
  // Catalogue data (shareable)
  final String title;
  final String author;
  final String? isbn;
  final String? publisher;
  final int? publicationYear;
  final int? pageCount;
  final String? bindingType;
  final String? secondaryContributors;
  final String? coverUrl;
  final String? synopsis;

  // Library placement (personal)
  final String? shelfLocation;
  final String? signatura;

  // Reading progress
  final String readingStatus;
  final int currentPage;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final List<ReadingLogDraft> logs;

  // Public opinion: rating (0-10 half stars) and comment
  final int? ratingHalfStars;
  final String? reviewText;

  // Private notes and tags
  final String? privateNotes;
  final List<TagDraft> tags;

  const BookDraft({
    required this.title,
    required this.author,
    this.isbn,
    this.publisher,
    this.publicationYear,
    this.pageCount,
    this.bindingType,
    this.secondaryContributors,
    this.coverUrl,
    this.synopsis,
    this.shelfLocation,
    this.signatura,
    this.readingStatus = 'unread',
    this.currentPage = 0,
    this.startedAt,
    this.finishedAt,
    this.logs = const [],
    this.ratingHalfStars,
    this.reviewText,
    this.privateNotes,
    this.tags = const [],
  });
}
