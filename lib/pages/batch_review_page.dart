import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/models/book_draft.dart';
import 'package:kittylogued/repositories/library_repository.dart';
import 'package:kittylogued/services/batch_import_queue.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/widgets/tag_editor.dart';

/// Full-screen, editable overview of a batch. Pops with the number of
/// books added; going back keeps the batch for later.
class BatchReviewPage extends StatefulWidget {
  final BatchImportQueue queue;
  final AppDatabase database;
  final LibraryRepository repository;
  final CoverCacheService coverCacheService;

  const BatchReviewPage({
    super.key,
    required this.queue,
    required this.database,
    required this.repository,
    required this.coverCacheService,
  });

  @override
  State<BatchReviewPage> createState() => _BatchReviewPageState();
}

class _BatchReviewPageState extends State<BatchReviewPage> {
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

  /// Marks existing ISBNs and excludes them from the batch import by default.
  Future<void> _markExisting() async {
    final existing = await (widget.database.select(
      widget.database.books,
    )..where((b) => b.deletedAt.isNull())).get();
    final isbns = existing
        .map((b) => BatchImportQueue.clean(b.isbn ?? ''))
        .where((s) => s.isNotEmpty)
        .toSet();
    if (!mounted) return;
    setState(() {
      for (final item in widget.queue.items) {
        if (isbns.contains(item.isbn)) {
          item.inLibrary = true;
          item.include = false;
        }
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
        final selected = items
            .where((i) => i.include && !i.inLibrary)
            .toList();
        final invalid = selected.where((i) => !i.isValid).length;
        final pending = widget.queue.pendingCount;
        final canSave =
            !_saving && pending == 0 && invalid == 0 && selected.isNotEmpty;

        var hint = '';
        if (pending > 0) {
          hint = 'Looking up $pending more…';
        } else if (invalid > 0) {
          hint = '$invalid selected book(s) need a title.';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Review batch (${items.length})'),
            actions: [
              TextButton(
                onPressed: _saving
                    ? null
                    : () {
                        widget.queue.clear();
                        Navigator.of(context).pop();
                      },
                child: const Text('Discard all'),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (pending > 0) const LinearProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ExpansionTile(
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
                  ),
                  SwitchListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return _BatchItemCard(
                                key: ObjectKey(item),
                                item: item,
                                onChanged: () {
                                  widget.queue.persist(item);
                                  setState(() {});
                                },
                                onRetry: () => widget.queue.retry(item),
                                onRemove: () => widget.queue.remove(item),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hint,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: canSave ? _save : null,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.library_add),
                    label: Text('Add ${selected.length} to library'),
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 6),
            Text(
              item.waitingForNetwork
                  ? 'Waiting for connection…'
                  : 'Looking up…',
              style: const TextStyle(fontSize: 12),
            ),
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
              onChanged: item.inLibrary
                  ? null
                  : (v) {
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
                          'Already in library — skipped',
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
                    onChanged: (v) {
                      item.author = v;
                      widget.onChanged();
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _isbn,
                          decoration: _dec('ISBN'),
                          onChanged: (v) {
                            item.isbn = v;
                            widget.onChanged();
                          },
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
                          onChanged: (v) {
                            item.publisher = v;
                            widget.onChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 76,
                        child: TextField(
                          controller: _year,
                          keyboardType: TextInputType.number,
                          decoration: _dec('Year'),
                          onChanged: (v) {
                            item.year = v;
                            widget.onChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 76,
                        child: TextField(
                          controller: _pages,
                          keyboardType: TextInputType.number,
                          decoration: _dec('Pages'),
                          onChanged: (v) {
                            item.pages = v;
                            widget.onChanged();
                          },
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
