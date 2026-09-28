import 'dart:io';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final coverCacheService = CoverCacheService();
  runApp(
    KittyloguedApp(database: database, coverCacheService: coverCacheService),
  );
}

/// Normalizes text for search: lowercases and strips Czech diacritics.
String _normalizeText(String input) {
  if (input.isEmpty) return '';
  var s = input.toLowerCase();

  const diacritics = {
    'á': 'a',
    'ä': 'a',
    'č': 'c',
    'ď': 'd',
    'é': 'e',
    'ě': 'e',
    'í': 'i',
    'ĺ': 'l',
    'ľ': 'l',
    'ň': 'n',
    'ó': 'o',
    'ö': 'o',
    'ô': 'o',
    'ŕ': 'r',
    'ř': 'r',
    'š': 's',
    'ť': 't',
    'ú': 'u',
    'ů': 'u',
    'ü': 'u',
    'ý': 'y',
    'ž': 'z',
  };

  diacritics.forEach((k, v) => s = s.replaceAll(k, v));
  return s;
}

class KittyloguedApp extends StatelessWidget {
  final AppDatabase database;
  final CoverCacheService coverCacheService;

  const KittyloguedApp({
    super.key,
    required this.database,
    required this.coverCacheService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kittylogued',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: BookCatalogPage(
        database: database,
        coverCacheService: coverCacheService,
      ),
    );
  }
}

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

  void _openAddBookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddBookDialog(
        database: widget.database,
        coverCacheService: widget.coverCacheService,
      ),
    );
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
                hintText: 'Search title, author, or ISBN...',
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

                final queryTokens = _normalizeText(_searchQuery)
                    .split(RegExp(r'\s+'))
                    .where((token) => token.isNotEmpty)
                    .toList();

                final filteredBooks = allBooks.where((book) {
                  if (queryTokens.isNotEmpty) {
                    final targetCombined = _normalizeText(
                      '${book.title} ${book.author} ${book.isbn ?? ""}',
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
                                        '${book.author}\nShelf: $shelf',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddBookDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),
    );
  }
}

class BookCoverThumbnail extends StatefulWidget {
  final String? isbn;
  final String? coverUrl;
  final CoverCacheService cacheService;

  const BookCoverThumbnail({
    super.key,
    required this.isbn,
    required this.coverUrl,
    required this.cacheService,
  });

  @override
  State<BookCoverThumbnail> createState() => _BookCoverThumbnailState();
}

class _BookCoverThumbnailState extends State<BookCoverThumbnail> {
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
    _resolveCover();
  }

  @override
  void didUpdateWidget(covariant BookCoverThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isbn != widget.isbn ||
        oldWidget.coverUrl != widget.coverUrl) {
      _resolveCover();
    }
  }

  Future<void> _resolveCover() async {
    final rawIsbn = widget.isbn;
    if (rawIsbn == null || rawIsbn.isEmpty) {
      if (mounted) {
        setState(() => _cachedFile = null);
      }
      return;
    }

    final file = await widget.cacheService.getCachedCover(rawIsbn);
    if (!mounted) return;

    if (file != null) {
      setState(() => _cachedFile = file);
      return;
    }

    final remote = widget.coverUrl;
    if (remote != null && remote.isNotEmpty) {
      final downloaded = await widget.cacheService.downloadAndCacheCover(
        rawIsbn: rawIsbn,
        remoteUrl: remote,
      );
      if (mounted && downloaded != null) {
        setState(() => _cachedFile = downloaded);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 44,
          height: 64,
          child: Image.file(
            _cachedFile!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          ),
        ),
      );
    }

    if (widget.coverUrl != null && widget.coverUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 44,
          height: 64,
          child: Image.network(
            widget.coverUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.white10,
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 44,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.book, size: 24, color: Colors.grey),
    );
  }
}

class AddBookDialog extends StatefulWidget {
  final AppDatabase database;
  final CoverCacheService coverCacheService;

  const AddBookDialog({
    super.key,
    required this.database,
    required this.coverCacheService,
  });

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _shelfController = TextEditingController();

  final _isbnLookupService = IsbnLookupService();
  bool _isLookingUp = false;
  String? _coverUrl;
  String _readingStatus = 'unread';

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _shelfController.dispose();
    super.dispose();
  }

  Future<void> _lookupIsbn() async {
    final rawIsbn = _isbnController.text.trim();
    if (rawIsbn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an ISBN first.')),
      );
      return;
    }

    setState(() {
      _isLookingUp = true;
    });

    final result = await _isbnLookupService.lookupByIsbn(rawIsbn);

    if (!mounted) return;

    setState(() {
      _isLookingUp = false;
    });

    if (result != null) {
      setState(() {
        _titleController.text = result.title;
        _authorController.text = result.author;
        _coverUrl = result.coverUrl;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Found: ${result.title}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No book found for ISBN "$rawIsbn".')),
      );
    }
  }

  Future<void> _saveBook() async {
    final formState = _formKey.currentState;
    if (formState != null && !formState.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final isbn = _isbnController.text.trim();
    final shelf = _shelfController.text.trim();

    if (isbn.isNotEmpty && _coverUrl != null && _coverUrl!.isNotEmpty) {
      await widget.coverCacheService.downloadAndCacheCover(
        rawIsbn: isbn,
        remoteUrl: _coverUrl!,
      );
    }

    await widget.database
        .into(widget.database.books)
        .insert(
          BooksCompanion.insert(
            title: title,
            author: author,
            isbn: drift.Value(isbn.isEmpty ? null : isbn),
            coverUrl: drift.Value(_coverUrl),
            shelfLocation: drift.Value(shelf.isEmpty ? null : shelf),
            readingStatus: drift.Value(_readingStatus),
          ),
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Book'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _isbnController,
                        decoration: const InputDecoration(
                          labelText: 'ISBN',
                          hintText: 'e.g. 9780451524935',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 56,
                      child: FilledButton.tonalIcon(
                        onPressed: _isLookingUp ? null : _lookupIsbn,
                        icon: _isLookingUp
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: const Text('Lookup'),
                      ),
                    ),
                  ],
                ),
                if (_coverUrl != null && _coverUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            width: 36,
                            height: 52,
                            child: Image.network(
                              _coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Cover artwork found',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: 'Author *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an author';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _shelfController,
                  decoration: const InputDecoration(
                    labelText: 'Shelf Location',
                    hintText: 'e.g. Living Room Shelf A',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reading Status',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SegmentedButton(
                  segments: const [
                    ButtonSegment(value: 'unread', label: Text('To Read')),
                    ButtonSegment(value: 'reading', label: Text('Reading')),
                    ButtonSegment(value: 'read', label: Text('Finished')),
                  ],
                  selected: {_readingStatus},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _readingStatus = newSelection.first.toString();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _saveBook, child: const Text('Save')),
      ],
    );
  }
}

class EditBookDialog extends StatefulWidget {
  final AppDatabase database;
  final CoverCacheService coverCacheService;
  final Book book;

  const EditBookDialog({
    super.key,
    required this.database,
    required this.coverCacheService,
    required this.book,
  });

  @override
  State<EditBookDialog> createState() => _EditBookDialogState();
}

class _EditBookDialogState extends State<EditBookDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _shelfController;

  final _isbnLookupService = IsbnLookupService();
  bool _isLookingUp = false;
  String? _coverUrl;
  late String _readingStatus;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book.title);
    _authorController = TextEditingController(text: book.author);
    _isbnController = TextEditingController(text: book.isbn ?? '');
    _shelfController = TextEditingController(text: book.shelfLocation ?? '');
    _coverUrl = book.coverUrl;
    _readingStatus = book.readingStatus;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _shelfController.dispose();
    super.dispose();
  }

  Future<void> _lookupIsbn() async {
    final rawIsbn = _isbnController.text.trim();
    if (rawIsbn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an ISBN first.')),
      );
      return;
    }

    setState(() {
      _isLookingUp = true;
    });

    final result = await _isbnLookupService.lookupByIsbn(rawIsbn);

    if (!mounted) return;

    setState(() {
      _isLookingUp = false;
    });

    if (result != null) {
      setState(() {
        _titleController.text = result.title;
        _authorController.text = result.author;
        _coverUrl = result.coverUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated metadata for: ${result.title}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No book found for ISBN "$rawIsbn".')),
      );
    }
  }

  Future<void> _updateBook() async {
    final formState = _formKey.currentState;
    if (formState != null && !formState.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final isbn = _isbnController.text.trim();
    final shelf = _shelfController.text.trim();

    if (isbn.isNotEmpty && _coverUrl != null && _coverUrl!.isNotEmpty) {
      await widget.coverCacheService.downloadAndCacheCover(
        rawIsbn: isbn,
        remoteUrl: _coverUrl!,
      );
    }

    await (widget.database.update(
      widget.database.books,
    )..where((tbl) => tbl.id.equals(widget.book.id))).write(
      BooksCompanion(
        title: drift.Value(title),
        author: drift.Value(author),
        isbn: drift.Value(isbn.isEmpty ? null : isbn),
        coverUrl: drift.Value(_coverUrl),
        shelfLocation: drift.Value(shelf.isEmpty ? null : shelf),
        readingStatus: drift.Value(_readingStatus),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Updated "$title"')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Book'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _isbnController,
                        decoration: const InputDecoration(
                          labelText: 'ISBN',
                          hintText: 'e.g. 9780451524935',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 56,
                      child: FilledButton.tonalIcon(
                        onPressed: _isLookingUp ? null : _lookupIsbn,
                        icon: _isLookingUp
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: const Text('Re-fetch'),
                      ),
                    ),
                  ],
                ),
                if (_coverUrl != null && _coverUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            width: 36,
                            height: 52,
                            child: Image.network(
                              _coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Cover artwork attached',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: 'Author *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an author';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _shelfController,
                  decoration: const InputDecoration(
                    labelText: 'Shelf Location',
                    hintText: 'e.g. Living Room Shelf A',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reading Status',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SegmentedButton(
                  segments: const [
                    ButtonSegment(value: 'unread', label: Text('To Read')),
                    ButtonSegment(value: 'reading', label: Text('Reading')),
                    ButtonSegment(value: 'read', label: Text('Finished')),
                  ],
                  selected: {_readingStatus},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _readingStatus = newSelection.first.toString();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _updateBook, child: const Text('Update')),
      ],
    );
  }
}
