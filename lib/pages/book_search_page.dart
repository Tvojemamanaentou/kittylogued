import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';
import 'package:kittylogued/utils/text_normalizer.dart';

/// One book (title + author) with every edition the catalogues returned.
class _WorkGroup {
  final String title;
  final String author;
  final List<BookLookupResult> editions;

  _WorkGroup(this.title, this.author, this.editions);
}

/// Full-screen search: by title/author, pick the book, then pick the
/// edition you own. Pops with the chosen [BookLookupResult].
class BookSearchPage extends StatefulWidget {
  final String? initialQuery;
  final AppDatabase database;

  const BookSearchPage({super.key, required this.database, this.initialQuery});

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final TextEditingController _queryController = TextEditingController();
  final IsbnLookupService _lookupService = IsbnLookupService();

  List<_WorkGroup> _groups = [];
  _WorkGroup? _selectedGroup;
  bool _isLoading = false;
  bool _hasSearched = false;
  List<Book> _libraryBooks = [];

  @override
  void initState() {
    super.initState();
    _loadLibraryBooks();
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _queryController.text = widget.initialQuery!.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) => _performSearch());
    }
  }

  Future<void> _loadLibraryBooks() async {
    final books = await (widget.database.select(widget.database.books)
          ..where((book) => book.deletedAt.isNull()))
        .get();
    if (mounted) setState(() => _libraryBooks = books);
  }

  bool _isInLibrary(BookLookupResult result) {
    final isbn = result.isbn?.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
    final title = normalizeText(result.title.trim());
    final author = normalizeText(result.author.trim());
    return _libraryBooks.any((book) {
      final existingIsbn = book.isbn
          ?.replaceAll(RegExp(r'[^0-9Xx]'), '')
          .toUpperCase();
      if (isbn != null && isbn.isNotEmpty && existingIsbn == isbn) return true;
      return normalizeText(book.title.trim()) == title &&
          normalizeText(book.author.trim()) == author;
    });
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
      final cover = e.coverUrl?.trim();
      if (cover != null && cover.isNotEmpty) return cover;
    }
    for (final edition in g.editions) {
      final isbn = edition.isbn?.replaceAll(RegExp(r'[^0-9Xx]'), '');
      if (isbn != null && isbn.isNotEmpty) {
        return 'https://covers.openlibrary.org/b/isbn/$isbn-M.jpg';
      }
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${group.author} • ${n == 1 ? "1 edition" : "$n editions"}',
              ),
              if (group.editions.any(_isInLibrary))
                const Text(
                  'Already in your library — check before adding',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
            ],
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
                title: Row(
                  children: [
                    Expanded(child: Text(headline)),
                    if (_isInLibrary(e))
                      const Tooltip(
                        message: 'Already in your library',
                        child: Icon(Icons.library_add_check, size: 18),
                      ),
                  ],
                ),
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

    return PopScope(
      // Back from the edition list returns to the results first.
      canPop: group == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _selectedGroup = null);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Search catalogues')),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                              _hasSearched
                                  ? 'No matching editions found.'
                                  : 'Enter a title or author above to search online.',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : _buildGroupList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
