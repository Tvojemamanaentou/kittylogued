import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/utils/text_normalizer.dart';
import 'package:kittylogued/widgets/add_book_dialog.dart';
import 'package:kittylogued/widgets/barcode_scanner_dialog.dart';
import 'package:kittylogued/widgets/book_cover_thumbnail.dart';
import 'package:kittylogued/widgets/edit_book_dialog.dart';

class BookCatalogPage extends StatefulWidget {
  final AppDatabase database;
  final CoverCacheService coverCacheService;

  const BookCatalogPage({
    super.key,
    required this.database,
    required this.coverCacheService,
  });

  @override
  State<BookCatalogPage> createState() => _BookCatalogPageState();
}

class _BookCatalogPageState extends State<BookCatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedShelf = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openEditBookDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (dialogContext) => EditBookDialog(
        database: widget.database,
        coverCacheService: widget.coverCacheService,
        book: book,
      ),
    );
  }

  Future<void> _deleteBook(BuildContext context, Book book) async {
    await (widget.database.delete(
      widget.database.books,
    )..where((tbl) => tbl.id.equals(book.id))).go();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${book.title}"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedStatus = 'all';
      _selectedShelf = 'all';
    });
    _searchFocusNode.requestFocus();
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String label;

    switch (status) {
      case 'reading':
        chipColor = Colors.orangeAccent;
        label = 'Reading';
        break;
      case 'read':
        chipColor = Colors.greenAccent;
        label = 'Finished';
        break;
      case 'unread':
      default:
        chipColor = Colors.blueGrey;
        label = 'To Read';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        border: Border.all(color: chipColor.withValues(alpha: 0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters =
        _searchQuery.isNotEmpty ||
        _selectedStatus != 'all' ||
        _selectedShelf != 'all';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kittylogued Library'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
            onPressed: () async {
              final scannedIsbn = await showDialog<String>(
                context: context,
                builder: (dialogContext) => const BarcodeScannerDialog(),
              );
              if (scannedIsbn != null && context.mounted) {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AddBookDialog(
                    database: widget.database,
                    coverCacheService: widget.coverCacheService,
                    initialIsbn: scannedIsbn,
                  ),
                );
              }
            },
          ),
          if (hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Reset filters',
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
              decoration: InputDecoration(
                hintText:
                    'Search title, author, ISBN, signatura, or publisher...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _searchFocusNode.requestFocus();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Status'),
                  selected: _selectedStatus == 'all',
                  onSelected: (_) => setState(() => _selectedStatus = 'all'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('To Read'),
                  selected: _selectedStatus == 'unread',
                  onSelected: (_) => setState(() => _selectedStatus = 'unread'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Reading'),
                  selected: _selectedStatus == 'reading',
                  onSelected: (_) =>
                      setState(() => _selectedStatus = 'reading'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Finished'),
                  selected: _selectedStatus == 'read',
                  onSelected: (_) => setState(() => _selectedStatus = 'read'),
                ),
              ],
            ),
          ),
          const Divider(height: 12),
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: widget.database.select(widget.database.books).watch(),
              builder: (context, snapshot) {
                if (!snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading catalog: ${snapshot.error}'),
                  );
                }

                final allBooks = snapshot.data ?? const <Book>[];

                if (allBooks.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No books in your catalog yet.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Click the + button to add your first book.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final Set<String> distinctShelves = <String>{};
                for (final book in allBooks) {
                  if (book.shelfLocation != null &&
                      book.shelfLocation!.trim().isNotEmpty) {
                    distinctShelves.add(book.shelfLocation!.trim());
                  }
                }
                final sortedShelves = distinctShelves.toList()..sort();

                final queryTokens = normalizeText(_searchQuery)
                    .split(RegExp(r'\s+'))
                    .where((token) => token.isNotEmpty)
                    .toList();

                final filteredBooks = allBooks.where((book) {
                  if (queryTokens.isNotEmpty) {
                    final targetCombined = normalizeText(
                      '${book.title} ${book.author} ${book.isbn ?? ""} '
                      '${book.signatura ?? ""} ${book.publisher ?? ""} '
                      '${book.secondaryContributors ?? ""}',
                    );
                    final targetSpaced = targetCombined.replaceAll(
                      RegExp(r'[^a-z0-9]'),
                      ' ',
                    );
                    final targetCollapsed = targetCombined.replaceAll(
                      RegExp(r'[^a-z0-9]'),
                      '',
                    );

                    final matchesAll = queryTokens.every((token) {
                      final cleanToken = token.replaceAll(
                        RegExp(r'[^a-z0-9]'),
                        '',
                      );
                      if (cleanToken.isEmpty) return true;

                      return targetSpaced.contains(token) ||
                          targetCollapsed.contains(cleanToken);
                    });

                    if (!matchesAll) return false;
                  }

                  if (_selectedStatus != 'all' &&
                      book.readingStatus != _selectedStatus) {
                    return false;
                  }

                  if (_selectedShelf != 'all') {
                    if (book.shelfLocation == null ||
                        book.shelfLocation!.trim() != _selectedShelf) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sortedShelves.isNotEmpty) ...[
                      Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shelves,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('All Shelves'),
                                selected: _selectedShelf == 'all',
                                onSelected: (_) =>
                                    setState(() => _selectedShelf = 'all'),
                              ),
                              for (final shelf in sortedShelves) ...[
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: Text(shelf),
                                  selected: _selectedShelf == shelf,
                                  onSelected: (_) =>
                                      setState(() => _selectedShelf = shelf),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 8),
                    ],
                    Expanded(
                      child: filteredBooks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No matching books found.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: _clearFilters,
                                    icon: const Icon(Icons.restart_alt),
                                    label: const Text('Reset Filters'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 12,
                              ),
                              itemCount: filteredBooks.length,
                              itemBuilder: (context, index) {
                                final book = filteredBooks[index];
                                final shelf =
                                    (book.shelfLocation != null &&
                                        book.shelfLocation!.isNotEmpty)
                                    ? book.shelfLocation!
                                    : 'Unassigned';
                                final hasSignatura =
                                    book.signatura != null &&
                                    book.signatura!.trim().isNotEmpty;

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: ListTile(
                                    onTap: () =>
                                        _openEditBookDialog(context, book),
                                    leading: BookCoverThumbnail(
                                      isbn: book.isbn,
                                      coverUrl: book.coverUrl,
                                      cacheService: widget.coverCacheService,
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            book.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatusChip(book.readingStatus),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${book.author}\nShelf: $shelf${hasSignatura ? "  •  Call #: ${book.signatura}" : ""}',
                                      ),
                                    ),
                                    isThreeLine: true,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.white70,
                                          ),
                                          tooltip: 'Edit book',
                                          onPressed: () => _openEditBookDialog(
                                            context,
                                            book,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                          ),
                                          tooltip: 'Delete book',
                                          onPressed: () =>
                                              _deleteBook(context, book),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
