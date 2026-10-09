import 'package:flutter/material.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';

/// Modal dialog allowing search by title and author with interactive selection.
class BookSearchDialog extends StatefulWidget {
  final String? initialQuery;

  const BookSearchDialog({super.key, this.initialQuery});

  @override
  State<BookSearchDialog> createState() => _BookSearchDialogState();
}

class _BookSearchDialogState extends State<BookSearchDialog> {
  final TextEditingController _queryController = TextEditingController();
  final IsbnLookupService _lookupService = IsbnLookupService();

  List<BookLookupResult> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _queryController.text = widget.initialQuery!.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) => _performSearch());
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final results = await _lookupService.searchBooks(query: query);

    if (!mounted) return;
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.travel_explore,
                    color: Colors.deepPurpleAccent,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Search Library Catalogs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Title, Author, or Keyword',
                        hintText: 'e.g. Karel Čapek Válka s mloky',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _performSearch,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                    ? Center(
                        child: Text(
                          _hasSearched ? 'No matching editions found.' : 'Enter a title or author above to search online.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          final yearStr = item.publicationYear != null
                              ? ' (${item.publicationYear})'
                              : '';
                          final publisherStr = item.publisher != null
                              ? ' • ${item.publisher}'
                              : '';

                          return ListTile(
                            leading: item.coverUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      item.coverUrl!,
                                      width: 36,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 36,
                                        height: 52,
                                        color: Colors.white12,
                                        child: const Icon(Icons.book, size: 20),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 36,
                                    height: 52,
                                    color: Colors.white12,
                                    child: const Icon(Icons.book, size: 20),
                                  ),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${item.author}$yearStr$publisherStr'
                              '${item.isbn != null ? "\nISBN: ${item.isbn}" : ""}',
                            ),
                            isThreeLine: item.isbn != null,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).pop(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
