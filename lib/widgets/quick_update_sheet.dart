import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/repository/library_repository.dart';
import 'package:kittylogued/utils/reading_progress.dart';
import 'package:kittylogued/widgets/reading_progress_bar.dart';
import 'package:kittylogued/widgets/star_rating.dart';

/// Small sheet to update the page, finish a book or rate it without opening
/// the full form. Opens on long-press (or right-click) in the catalogue.
Future<void> showQuickUpdateSheet(
  BuildContext context, {
  required Book book,
  required LibraryRepository repository,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _QuickUpdateBody(book: book, repository: repository),
  );
}

class _QuickUpdateBody extends StatefulWidget {
  final Book book;
  final LibraryRepository repository;

  const _QuickUpdateBody({required this.book, required this.repository});

  @override
  State<_QuickUpdateBody> createState() => _QuickUpdateBodyState();
}

class _QuickUpdateBodyState extends State<_QuickUpdateBody> {
  late int _page = widget.book.currentPage;
  int? _rating;
  bool _ratingTouched = false;
  late final TextEditingController _pageController;

  int? get _total =>
      (widget.book.pageCount ?? 0) > 0 ? widget.book.pageCount : null;

  @override
  void initState() {
    super.initState();
    _rating = widget.book.ratingHalfStars;
    _pageController = TextEditingController(
      text: _page > 0 ? '$_page' : '',
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _setPage(int value) {
    final clamped = ReadingProgress.clampPage(value, _total);
    setState(() {
      _page = clamped;
      _pageController.text = clamped > 0 ? '$clamped' : '';
    });
  }

  Future<void> _save() async {
    await widget.repository.quickUpdate(
      widget.book,
      page: _page,
      rating: _rating,
      updateRating: _ratingTouched,
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _finish() async {
    if (_ratingTouched) {
      await widget.repository.quickUpdate(
        widget.book,
        page: _page,
        rating: _rating,
        updateRating: true,
      );
    }
    final fresh = widget.book;
    await widget.repository.markRead(fresh);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;
    final status = ReadingProgress.statusForPage(_page, total);
    final fraction = ReadingProgress.fraction(status, _page, total);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              widget.book.author,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (total != null) ...[
              ReadingProgressBar(status: status, fraction: fraction, height: 10),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: '-10 pages',
                    icon: const Icon(Icons.remove),
                    onPressed: () => _setPage(_page - 10),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _pageController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) =>
                          setState(() => _page = ReadingProgress.clampPage(
                            int.tryParse(v.trim()) ?? 0,
                            total,
                          )),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: '+10 pages',
                    icon: const Icon(Icons.add),
                    onPressed: () => _setPage(_page + 10),
                  ),
                  const SizedBox(width: 12),
                  Text('of $total pages'),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('+1'),
                    onPressed: () => _setPage(_page + 1),
                  ),
                  ActionChip(
                    label: const Text('+25'),
                    onPressed: () => _setPage(_page + 25),
                  ),
                  ActionChip(
                    label: const Text('+50'),
                    onPressed: () => _setPage(_page + 50),
                  ),
                ],
              ),
            ] else
              const Text(
                'Add a page count in the full editor to track pages.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                StarRating(
                  value: _rating,
                  size: 32,
                  onChanged: (v) => setState(() {
                    _rating = v;
                    _ratingTouched = true;
                  }),
                ),
                const SizedBox(width: 10),
                Text(StarRating.label(_rating)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _finish,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark finished'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
