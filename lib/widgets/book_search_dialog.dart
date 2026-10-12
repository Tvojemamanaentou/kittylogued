import 'package:flutter/material.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';
import 'package:kittylogued/utils/text_normalizer.dart';

/// One book (title + author) with every edition the catalogues returned.
class _WorkGroup {
  final String title;
  final String author;
  final List<BookLookupResult> editions;

  _WorkGroup(this.title, this.author, this.editions);
}

/// Modal dialog: search by title/author, pick the book, then pick the
/// edition you own. Pops with the chosen [BookLookupResult].
class BookSearchDialog extends StatefulWidget {
  final String? initialQuery;

  const BookSearchDialog({super.key, this.initialQuery});

  @override
  State<BookSearchDialog> createState() => _BookSearchDialogState();
}

class _BookSearchDialogState extends State<BookSearchDialog> {
  final TextEditingController _queryController = TextEditingController();
  final IsbnLookupService _lookupService = IsbnLookupService();

  List<_WorkGroup> _groups = [];
  _WorkGroup? _selectedGroup;
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

  /// Groups results that share a title and first author into one book.
  List<_WorkGroup> _group(List<BookLookupResult> results) {
    final byKey = <String, _WorkGroup>{};
    for (final r in results) {
      final firstAuthor = r.author.split(',').first;
      final key = '${normalizeText(r.title)}|${normalizeText(firstAuthor)}';
      final group = byKey.putIfAbsent(
        key,
        () => _WorkGroup(r.title, r.author, []),
      );
      group.editions.add(r);
    }
    for (final g in byKey.values) {
      g.editions.sort(
        (a, b) => (b.publicationYear ?? 0).compareTo(a.publicationYear ?? 0),
      );
    }
    return byKey.values.toList();
  }

  Future<void> _performSearch() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _selectedGroup = null;
    });

    final results = await _lookupService.searchBooks(query: query);

    if (!mounted) return;
    setState(() {
      _groups = _group(results);
      _isLoading = false;
    });
  }

  Widget _cover(String? url) {
    final placeholder = Container(
      width: 36,
      height: 52,
      color: Colors.grey.withValues(alpha: 0.2),
      child: const Icon(Icons.book, size: 20),
    );
    if (url == null) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        url,
        width: 36,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }

  String? _firstCover(_WorkGroup g) {
    for (final e in g.editions) {
      if (e.coverUrl != null) return e.coverUrl;
    }
    return null;
  }

  /// Fills in a missing page count from other catalogues, then returns.
  Future<void> _pick(BookLookupResult result) async {
    setState(() => _isLoading = true);
    final enriched = await _lookupService.withPageCount(result);
    if (!mounted) return;
    Navigator.of(context).pop(enriched);
  }

  void _onGroupTap(_WorkGroup group) {
    if (group.editions.length == 1) {
      _pick(group.editions.first);
    } else {
      setState(() => _selectedGroup = group);
    }
  }

  Widget _buildGroupList() {
    return ListView.separated(
      itemCount: _groups.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final group = _groups[index];
        final n = group.editions.length;
        return ListTile(
          leading: _cover(_firstCover(group)),
          title: Text(
            group.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${group.author} • ${n == 1 ? "1 edition" : "$n editions"}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _onGroupTap(group),
        );
      },
    );
  }

  Widget _buildEditionList(_WorkGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back to results',
              onPressed: () => setState(() => _selectedGroup = null),
            ),
            Expanded(
              child: Text(
                group.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 6),
          child: Text(
            'Tap the edition you own.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: group.editions.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final e = group.editions[index];
              final headline = [
                e.publisher ?? 'Unknown publisher',
                if (e.publicationYear != null) '${e.publicationYear}',
              ].join(' • ');
              final details = [
                if (e.isbn != null) 'ISBN: ${e.isbn}',
                if (e.pageCount != null) '${e.pageCount} pages',
                if (e.language != null) e.language!,
              ].join(' • ');
              return ListTile(
                leading: _cover(e.coverUrl),
                title: Text(headline),
                subtitle: details.isEmpty ? null : Text(details),
                trailing: const Icon(Icons.check_circle_outline),
                onTap: () => _pick(e),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = _selectedGroup;

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
                    : group != null
                    ? _buildEditionList(group)
                    : _groups.isEmpty
                    ? Center(
                        child: Text(
                          _hasSearched ? 'No matching editions found.' : 'Enter a title or author above to search online.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : _buildGroupList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
