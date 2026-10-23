import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/models/book_draft.dart';
import 'package:kittylogued/repositories/library_repository.dart';
import 'package:kittylogued/services/batch_import_queue.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/widgets/tag_editor.dart';

/// Editable overview of a batch. Pops with the number of books added.
class BatchReviewDialog extends StatefulWidget {
  final BatchImportQueue queue;
  final AppDatabase database;
  final LibraryRepository repository;
  final CoverCacheService coverCacheService;

  const BatchReviewDialog({
    super.key,
    required this.queue,
    required this.database,
    required this.repository,
    required this.coverCacheService,
  });

  @override
  State<BatchReviewDialog> createState() => _BatchReviewDialogState();
}

class _BatchReviewDialogState extends State<BatchReviewDialog> {
  final TextEditingController _shelfController = TextEditingController();
  List<TagDraft> _tags = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _markExisting();
  }

  @override
  void dispose() {
    _shelfController.dispose();
    super.dispose();
  }

  /// Flags books whose ISBN is already in the library (still selected).
  Future<void> _markExisting() async {
    final existing = await widget.database.select(widget.database.books).get();
    final isbns = existing
        .map((b) => BatchImportQueue.clean(b.isbn ?? ''))
        .where((s) => s.isNotEmpty)
        .toSet();
    if (!mounted) return;
    setState(() {
      for (final item in widget.queue.items) {
        if (isbns.contains(item.isbn)) item.inLibrary = true;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final added = await widget.queue.commit(
      repository: widget.repository,
      coverCache: widget.coverCacheService,
      shelf: _shelfController.text,
      tags: _tags,
    );
    if (mounted) Navigator.of(context).pop(added);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.queue,
      builder: (context, _) {
        final items = widget.queue.items;
        final selected = items.where((i) => i.include).toList();
        final invalid = selected.where((i) => !i.isValid).length;
        final pending = widget.queue.pendingCount;
        final canSave =
            !_saving && pending == 0 && invalid == 0 && selected.isNotEmpty;

        String hint = '';
        if (pending > 0) {
          hint = 'Looking up $pending more…';
        } else if (invalid > 0) {
          hint = '$invalid selected book(s) need a title.';
        }

        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fact_check_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Review batch (${items.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Close (keeps the batch)',
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  if (pending > 0) const LinearProgressIndicator(),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Apply to all: shelf & tags'),
                    children: [
                      TextField(
                        controller: _shelfController,
                        decoration: const InputDecoration(
                          labelText: 'Shelf Location',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TagEditor(
                        database: widget.database,
                        tags: _tags,
                        onChanged: (t) => setState(() => _tags = t),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  SwitchListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text('Select all'),
                    value: items.isNotEmpty && items.every((i) => i.include),
                    onChanged: items.isEmpty
                        ? null
                        : (value) => setState(() {
                            for (final i in items) {
                              i.include = value;
                            }
                          }),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: items.isEmpty
                        ? const Center(
                            child: Text(
                              'Nothing to review.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return _BatchItemCard(
                                key: ObjectKey(item),
                                item: item,
                                onChanged: () => setState(() {}),
                                onRetry: () => widget.queue.retry(item),
                                onRemove: () => widget.queue.remove(item),
                              );
                            },
                          ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () {
                                widget.queue.clear();
                                Navigator.of(context).pop();
                              },
                        child: const Text('Discard all'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hint,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: canSave ? _save : null,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.library_add),
                        label: Text('Add ${selected.length} to library'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BatchItemCard extends StatefulWidget {
  final BatchItem item;
  final VoidCallback onChanged;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  const _BatchItemCard({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onRetry,
    required this.onRemove,
  });

  @override
  State<_BatchItemCard> createState() => _BatchItemCardState();
}

class _BatchItemCardState extends State<_BatchItemCard> {
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _isbn;
  late final TextEditingController _publisher;
  late final TextEditingController _year;
  late final TextEditingController _pages;
  late int _seenVersion;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _title = TextEditingController(text: i.title);
    _author = TextEditingController(text: i.author);
    _isbn = TextEditingController(text: i.isbn);
    _publisher = TextEditingController(text: i.publisher);
    _year = TextEditingController(text: i.year);
    _pages = TextEditingController(text: i.pages);
    _seenVersion = i.lookupVersion;
    i.addListener(_onItemChanged);
  }

  /// A lookup finished: fill the fields with the fresh data.
  void _onItemChanged() {
    final i = widget.item;
    if (i.lookupVersion != _seenVersion) {
      _seenVersion = i.lookupVersion;
      _title.text = i.title;
      _author.text = i.author;
      _publisher.text = i.publisher;
      _year.text = i.year;
      _pages.text = i.pages;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.item.removeListener(_onItemChanged);
    for (final c in [_title, _author, _isbn, _publisher, _year, _pages]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _statusChip() {
    final item = widget.item;
    switch (item.status) {
      case BatchLookupStatus.pending:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 6),
            Text('Looking up…', style: TextStyle(fontSize: 12)),
          ],
        );
      case BatchLookupStatus.found:
        return const Text(
          'Found',
          style: TextStyle(fontSize: 12, color: Colors.green),
        );
      case BatchLookupStatus.notFound:
        return const Text(
          'Not found – fill in manually',
          style: TextStyle(fontSize: 12, color: Colors.orange),
        );
    }
  }

  InputDecoration _dec(String label, {String? error}) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
    errorText: error,
  );

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final cover = item.coverUrl;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: item.include,
              onChanged: (v) {
                item.include = v ?? false;
                widget.onChanged();
                setState(() {});
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 40,
                  height: 58,
                  child: (cover != null && cover.isNotEmpty)
                      ? Image.network(
                          cover,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.book, color: Colors.grey),
                        )
                      : const Icon(Icons.book, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _statusChip(),
                      if (item.inLibrary) ...[
                        const SizedBox(width: 10),
                        const Text(
                          'Already in library',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _title,
                    decoration: _dec(
                      'Title',
                      error: item.include && !item.isValid ? 'Required' : null,
                    ),
                    onChanged: (v) {
                      item.title = v;
                      widget.onChanged();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _author,
                    decoration: _dec('Author'),
                    onChanged: (v) => item.author = v,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _isbn,
                          decoration: _dec('ISBN'),
                          onChanged: (v) => item.isbn = v,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Look up again',
                        onPressed: widget.onRetry,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _publisher,
                          decoration: _dec('Publisher'),
                          onChanged: (v) => item.publisher = v,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 76,
                        child: TextField(
                          controller: _year,
                          keyboardType: TextInputType.number,
                          decoration: _dec('Year'),
                          onChanged: (v) => item.year = v,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 76,
                        child: TextField(
                          controller: _pages,
                          keyboardType: TextInputType.number,
                          decoration: _dec('Pages'),
                          onChanged: (v) => item.pages = v,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Remove from batch',
              onPressed: widget.onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
