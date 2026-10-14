import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/utils/reading_progress.dart';
import 'package:kittylogued/widgets/book_cover_thumbnail.dart';
import 'package:kittylogued/widgets/cover_viewer.dart';
import 'package:kittylogued/widgets/reading_progress_bar.dart';
import 'package:kittylogued/widgets/star_rating.dart';

/// Right-hand panel of the catalogue on wide windows: everything about the
/// selected book, with quick buttons.
class BookDetailPane extends StatelessWidget {
  final Book book;
  final List<Tag> tags;
  final CoverCacheService coverCache;
  final VoidCallback onEdit;
  final VoidCallback onQuickUpdate;
  final VoidCallback onLendOrReturn;

  /// The active loan when this book is lent out.
  final Loan? loan;

  const BookDetailPane({
    super.key,
    required this.book,
    required this.tags,
    required this.coverCache,
    required this.onEdit,
    required this.onQuickUpdate,
    required this.onLendOrReturn,
    this.loan,
  });

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _section(String title, Widget child, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _info(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLoan = loan;
    final total = book.pageCount;
    final hasTotal = total != null && total > 0;
    final fraction = ReadingProgress.fraction(
      book.readingStatus,
      book.currentPage,
      total,
    );
    final statusLabel = {
      'unread': 'To read',
      'reading': 'Reading',
      'read': 'Finished',
    }[book.readingStatus] ?? book.readingStatus;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => showCoverViewer(
                context,
                title: book.title,
                isbn: book.isbn,
                coverUrl: book.coverUrl,
                cacheService: coverCache,
              ),
              child: BookCoverThumbnail(
                isbn: book.isbn,
                coverUrl: book.coverUrl,
                cacheService: coverCache,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(book.author, style: const TextStyle(color: Colors.grey)),
                  if (book.publisher != null || book.publicationYear != null)
                    Text(
                      [
                        if (book.publisher != null) book.publisher!,
                        if (book.publicationYear != null)
                          '${book.publicationYear}',
                      ].join(' • '),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
            ),
            OutlinedButton.icon(
              onPressed: onQuickUpdate,
              icon: const Icon(Icons.bolt, size: 18),
              label: const Text('Quick update'),
            ),
            OutlinedButton.icon(
              onPressed: onLendOrReturn,
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: Text(activeLoan == null ? 'Lend' : 'Mark returned'),
            ),
          ],
        ),
        if (activeLoan != null)
          _section(
            'Lent out',
            Text(
              'Lent to ${activeLoan.personName} since ${_fmt(activeLoan.startedAt)}'
              '${activeLoan.dueAt != null ? ' • due ${_fmt(activeLoan.dueAt!)}' : ''}',
            ),
            icon: Icons.swap_horiz,
          ),
        _section(
          statusLabel,
          Row(
            children: [
              Expanded(
                child: ReadingProgressBar(
                  status: book.readingStatus,
                  fraction: fraction,
                  height: 8,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                hasTotal
                    ? '${book.readingStatus == 'read' ? total : book.currentPage}/$total'
                    : '-',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          icon: Icons.auto_stories,
        ),
        _section(
          'Rating',
          Row(
            children: [
              StarRating(value: book.ratingHalfStars, size: 22),
              const SizedBox(width: 8),
              Text(StarRating.label(book.ratingHalfStars)),
            ],
          ),
          icon: Icons.public,
        ),
        if (book.reviewText != null && book.reviewText!.trim().isNotEmpty)
          _section('Comment', Text(book.reviewText!), icon: Icons.public),
        if (tags.isNotEmpty)
          _section(
            'Tags',
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final tag in tags)
                  Chip(
                    avatar: Icon(
                      tag.isPublic ? Icons.public : Icons.lock_outline,
                      size: 14,
                    ),
                    label: Text(tag.name),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            icon: Icons.sell_outlined,
          ),
        if (book.privateNotes != null && book.privateNotes!.trim().isNotEmpty)
          _section(
            'Private notes',
            Text(book.privateNotes!),
            icon: Icons.lock_outline,
          ),
        if (book.synopsis != null && book.synopsis!.trim().isNotEmpty)
          _section('Synopsis', Text(book.synopsis!), icon: Icons.notes),
        _section(
          'Details',
          Column(
            children: [
              _info('ISBN', book.isbn),
              _info('Shelf', book.shelfLocation),
              _info('Signatura', book.signatura),
              _info('Binding', book.bindingType),
              _info('Contributors', book.secondaryContributors),
              _info('Pages', hasTotal ? '$total' : null),
              _info('Started', book.startedAt == null ? null : _fmt(book.startedAt!)),
              _info(
                'Finished',
                book.finishedAt == null ? null : _fmt(book.finishedAt!),
              ),
            ],
          ),
          icon: Icons.info_outline,
        ),
      ],
    );
  }
}
