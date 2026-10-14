import 'package:flutter/material.dart';
import 'package:kittylogued/utils/reading_progress.dart';
import 'package:kittylogued/widgets/reading_progress_bar.dart';

/// The main input for reading progress: one big "current page" box.
/// The status (to read / reading / finished) follows the page automatically;
/// "Mark finished" and "Start over" cover the rest.
class ReadingProgressField extends StatefulWidget {
  final String status;
  final int currentPage;
  final int? totalPages;
  final void Function(String status, int currentPage) onChanged;

  const ReadingProgressField({
    super.key,
    required this.status,
    required this.currentPage,
    required this.totalPages,
    required this.onChanged,
  });

  @override
  State<ReadingProgressField> createState() => _ReadingProgressFieldState();
}

class _ReadingProgressFieldState extends State<ReadingProgressField> {
  late final TextEditingController _pageController;

  bool get _hasTotal => widget.totalPages != null && widget.totalPages! > 0;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(
      text: widget.currentPage > 0 ? widget.currentPage.toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant ReadingProgressField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the box in sync when the page was changed by a button.
    final typed = int.tryParse(_pageController.text.trim()) ?? 0;
    if (typed != widget.currentPage) {
      _pageController.text = widget.currentPage > 0
          ? widget.currentPage.toString()
          : '';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _setPage(int page) {
    final clamped = ReadingProgress.clampPage(page, widget.totalPages);
    widget.onChanged(
      ReadingProgress.statusForPage(clamped, widget.totalPages),
      clamped,
    );
  }

  void _markFinished() {
    widget.onChanged(
      'read',
      _hasTotal ? widget.totalPages! : widget.currentPage,
    );
  }

  void _startOver() => widget.onChanged('unread', 0);

  String get _statusLabel => switch (widget.status) {
    'read' => 'Finished',
    'reading' => 'Reading',
    _ => 'To read',
  };

  @override
  Widget build(BuildContext context) {
    final total = widget.totalPages;
    final fraction = ReadingProgress.fraction(
      widget.status,
      widget.currentPage,
      total,
    );
    final step = ReadingProgress.stepFor(widget.status, fraction);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Current page',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              tooltip: '-10 pages',
              icon: const Icon(Icons.remove),
              onPressed: () => _setPage(widget.currentPage - 10),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 130,
              child: TextField(
                controller: _pageController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: '0',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => _setPage(int.tryParse(v.trim()) ?? 0),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              tooltip: '+10 pages',
              icon: const Icon(Icons.add),
              onPressed: () => _setPage(widget.currentPage + 10),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _hasTotal
              ? 'of $total pages'
              : 'Add the page count in the Book tab to see your progress bar',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            ActionChip(
              label: const Text('+1'),
              onPressed: () => _setPage(widget.currentPage + 1),
            ),
            ActionChip(
              label: const Text('+5'),
              onPressed: () => _setPage(widget.currentPage + 5),
            ),
            ActionChip(
              label: const Text('+25'),
              onPressed: () => _setPage(widget.currentPage + 25),
            ),
          ],
        ),
        if (_hasTotal || widget.status == 'read') ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ReadingProgressBar(
                  status: widget.status,
                  fraction: fraction,
                  height: 10,
                ),
              ),
              const SizedBox(width: 10),
              Text('${(fraction * 100).round()}%'),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: ReadingProgressBar.stepColors[step],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _statusLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: widget.status == 'unread' ? null : _startOver,
                  child: const Text('Start over'),
                ),
                const SizedBox(width: 4),
                FilledButton.tonalIcon(
                  onPressed: widget.status == 'read' ? null : _markFinished,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Mark finished'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
