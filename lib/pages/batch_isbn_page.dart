import 'package:flutter/material.dart';
import 'package:kittylogued/services/batch_import_queue.dart';

/// Type several ISBNs one after another. Each one is sent to the queue and
/// looked up in the background while you keep typing.
/// Pops `true` when the user wants to review the batch.
class BatchIsbnPage extends StatefulWidget {
  final BatchImportQueue queue;

  const BatchIsbnPage({super.key, required this.queue});

  @override
  State<BatchIsbnPage> createState() => _BatchIsbnPageState();
}

class _BatchIsbnPageState extends State<BatchIsbnPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  String? _error;
  String? _selectedUid;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    final clean = BatchImportQueue.clean(raw);
    if (clean.length != 10 && clean.length != 13) {
      setState(() => _error = 'ISBN must be 10 or 13 characters.');
      return;
    }
    final added = widget.queue.add(clean);
    if (added) _selectedUid = clean;
    setState(() => _error = added ? null : 'Already in this batch.');
    _controller.clear();
    _focus.requestFocus();
  }

  Widget _statusIcon(BatchItem item) {
    switch (item.status) {
      case BatchLookupStatus.pending:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case BatchLookupStatus.found:
        return const Icon(Icons.check_circle, size: 18, color: Colors.green);
      case BatchLookupStatus.notFound:
        return const Icon(Icons.help_outline, size: 18, color: Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.queue,
      builder: (context, _) {
        final items = widget.queue.items;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Batch ISBN entry'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Single-book mode'),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.library_add_check_outlined),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Batch scan is on',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text('${items.length} queued'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controller,
                      focusNode: _focus,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'ISBN',
                        hintText: 'Type or paste, then press Enter',
                        border: const OutlineInputBorder(),
                        errorText: _error,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'Add to batch',
                          onPressed: _submit,
                        ),
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final selected = items.isEmpty
                              ? null
                              : items.firstWhere(
                                  (item) => item.uid == _selectedUid,
                                  orElse: () => items.last,
                                );
                          final queueList = items.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No ISBNs yet.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView(
                                  children: [
                                    for (final item in items.reversed)
                                      ListTile(
                                        selected: item.uid == _selectedUid,
                                        leading: _statusIcon(item),
                                        title: Text(
                                          item.title.isNotEmpty
                                              ? item.title
                                              : item.isbn,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: item.title.isNotEmpty
                                            ? Text(item.isbn)
                                            : null,
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                          tooltip: 'Remove',
                                          onPressed: () {
                                            widget.queue.remove(item);
                                            if (_selectedUid == item.uid) {
                                              setState(
                                                () => _selectedUid = null,
                                              );
                                            }
                                          },
                                        ),
                                        onTap: () => setState(
                                          () => _selectedUid = item.uid,
                                        ),
                                      ),
                                  ],
                                );
                          if (constraints.maxWidth < 800 || selected == null) {
                            return queueList;
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: queueList),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: ListenableBuilder(
                                      listenable: selected,
                                      builder: (context, _) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.menu_book_outlined,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            selected.title.isEmpty
                                                ? 'Looking up book details'
                                                : selected.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            selected.author.isEmpty
                                                ? selected.isbn
                                                : selected.author,
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            key: ValueKey(
                                              'batch-pages-${selected.uid}',
                                            ),
                                            initialValue: selected.pages,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Page count',
                                              border: OutlineInputBorder(),
                                              helperText: 'You can correct missing or incomplete metadata now.',
                                            ),
                                            onChanged: (value) {
                                              selected.pages = value;
                                              widget.queue.persist(selected);
                                            },
                                          ),
                                          const Spacer(),
                                          Text(
                                            'ISBN: ${selected.isbn}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AnimatedScale(
              key: ValueKey('batch-review-cta-${items.length}'),
              scale: items.isEmpty ? 1 : 1.02,
              duration: const Duration(milliseconds: 180),
              child: FilledButton.icon(
                onPressed: items.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.fact_check_outlined),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: Text(
                    'Continue to review (${items.length})',
                    key: ValueKey(items.length),
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
