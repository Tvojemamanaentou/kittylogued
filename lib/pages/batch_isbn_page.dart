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
              TextButton.icon(
                onPressed: items.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.fact_check_outlined),
                label: Text('Review (${items.length})'),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
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
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: items.isEmpty
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
                                      icon: const Icon(Icons.close, size: 18),
                                      tooltip: 'Remove',
                                      onPressed: () =>
                                          widget.queue.remove(item),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
