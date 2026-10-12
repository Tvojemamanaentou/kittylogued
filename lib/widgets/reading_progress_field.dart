import 'package:flutter/material.dart';
import 'package:kittylogued/utils/reading_progress.dart';
import 'package:kittylogued/widgets/reading_progress_bar.dart';

/// Reading status + progress bar. Typing a page number moves the bar and
/// updates the status automatically (0 = To Read, last page = Finished).
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
    // Keep the text box in sync when the page was changed by the status buttons.
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

  void _onStatusSelected(String status) {
    switch (status) {
      case 'unread':
        widget.onChanged('unread', 0);
        break;
      case 'read':
        widget.onChanged(
          'read',
          _hasTotal ? widget.totalPages! : widget.currentPage,
        );
        break;
      default:
        widget.onChanged('reading', widget.currentPage);
    }
  }

  void _onPageTyped(String text) {
    final raw = int.tryParse(text.trim()) ?? 0;
    final page = ReadingProgress.clampPage(raw, widget.totalPages);
    widget.onChanged(
      ReadingProgress.statusForPage(page, widget.totalPages),
      page,
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.totalPages;
    final fraction = ReadingProgress.fraction(
      widget.status,
      widget.currentPage,
      total,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'unread', label: Text('To Read')),
            ButtonSegment(value: 'reading', label: Text('Reading')),
            ButtonSegment(value: 'read', label: Text('Finished')),
          ],
          selected: {widget.status},
          onSelectionChanged: (s) => _onStatusSelected(s.first),
        ),
        const SizedBox(height: 12),
        if (_hasTotal) ...[
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
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _pageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Current page',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: _onPageTyped,
                ),
              ),
              const SizedBox(width: 10),
              Text('of $total pages'),
            ],
          ),
        ] else
          const Text(
            'Add a page count (Bibliographic tab) to track progress by page.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }
}
