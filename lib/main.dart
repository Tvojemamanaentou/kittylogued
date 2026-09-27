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

class BookCatalogPage extends StatelessWidget {
  final AppDatabase database;
  final CoverCacheService coverCacheService;

  const BookCatalogPage({
    super.key,
    required this.database,
    required this.coverCacheService,
  });

  void _openAddBookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddBookDialog(
        database: database,
        coverCacheService: coverCacheService,
      ),
    );
  }

  Future _deleteBook(BuildContext context, Book book) async {
    await (database.delete(
      database.books,
    )..where((tbl) => tbl.id.equals(book.id))).go();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "' + book.title + '"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kittylogued Library'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: database.select(database.books).watch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading catalog: ' + snapshot.error.toString(),
              ),
            );
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final shelf =
                  (book.shelfLocation != null && book.shelfLocation!.isNotEmpty)
                  ? book.shelfLocation!
                  : 'Unassigned';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: BookCoverThumbnail(
                    isbn: book.isbn,
                    coverUrl: book.coverUrl,
                    cacheService: coverCacheService,
                  ),
                  title: Text(
                    book.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(book.author + '\nShelf: ' + shelf),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Delete book',
                    onPressed: () => _deleteBook(context, book),
                  ),
                ),
              );
            },
          );
        },
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
  State createState() => _BookCoverThumbnailState();
}

class _BookCoverThumbnailState extends State {
  BookCoverThumbnail get _widget => widget as BookCoverThumbnail;
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
    _resolveCover();
  }

  @override
  void didUpdateWidget(covariant StatefulWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget as BookCoverThumbnail;
    if (old.isbn != _widget.isbn || old.coverUrl != _widget.coverUrl) {
      _resolveCover();
    }
  }

  Future _resolveCover() async {
    final rawIsbn = _widget.isbn;
    if (rawIsbn == null || rawIsbn.isEmpty) {
      if (mounted) setState(() => _cachedFile = null);
      return;
    }

    // 1. Check local disk first
    final file = await _widget.cacheService.getCachedCover(rawIsbn);
    if (!mounted) return;

    if (file != null) {
      setState(() => _cachedFile = file);
      return;
    }

    // 2. If not on disk but remote URL exists, download and cache in background
    final remote = _widget.coverUrl;
    if (remote != null && remote.isNotEmpty) {
      final downloaded = await _widget.cacheService.downloadAndCacheCover(
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

    if (_widget.coverUrl != null && _widget.coverUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 44,
          height: 64,
          child: Image.network(
            _widget.coverUrl!,
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
  State createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State {
  AddBookDialog get _dialog => widget as AddBookDialog;

  final _formKey = GlobalKey();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _shelfController = TextEditingController();

  final _isbnLookupService = IsbnLookupService();
  bool _isLookingUp = false;
  String? _coverUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _shelfController.dispose();
    super.dispose();
  }

  Future _lookupIsbn() async {
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
          .showSnackBar(SnackBar(content: Text('Found: ' + result.title)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No book found for ISBN "' + rawIsbn + '".')),
      );
    }
  }

  Future _saveBook() async {
    final formState = _formKey.currentState;
    if (formState is FormState) {
      if (!formState.validate()) {
        return;
      }
    }

    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final isbn = _isbnController.text.trim();
    final shelf = _shelfController.text.trim();

    // Cache the cover image on local disk before writing to the database
    if (isbn.isNotEmpty && _coverUrl != null && _coverUrl!.isNotEmpty) {
      await _dialog.coverCacheService.downloadAndCacheCover(
        rawIsbn: isbn,
        remoteUrl: _coverUrl!,
      );
    }

    await _dialog.database
        .into(_dialog.database.books)
        .insert(
          BooksCompanion.insert(
            title: title,
            author: author,
            isbn: drift.Value(isbn.isEmpty ? null : isbn),
            coverUrl: drift.Value(_coverUrl),
            shelfLocation: drift.Value(shelf.isEmpty ? null : shelf),
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
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
