import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';
import 'package:kittylogued/utils/book_identifier.dart';
import 'package:kittylogued/widgets/book_search_dialog.dart';

class AddBookDialog extends StatefulWidget {
  final AppDatabase database;
  final CoverCacheService coverCacheService;
  final String? initialIsbn;
  final BookLookupResult? initialResult;

  const AddBookDialog({
    super.key,
    required this.database,
    required this.coverCacheService,
    this.initialIsbn,
    this.initialResult,
  });

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _shelfController = TextEditingController();

  final _signaturaController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _pagesController = TextEditingController();
  final _contributorsController = TextEditingController();
  final _notesController = TextEditingController();

  final _isbnLookupService = IsbnLookupService();
  bool _isLookingUp = false;
  String? _coverUrl;
  String _readingStatus = 'unread';
  String _bindingType = 'paperback';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialIsbn != null && widget.initialIsbn!.isNotEmpty) {
      _isbnController.text = widget.initialIsbn!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookupIsbn());
    }
    if (widget.initialResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyLookupResult(widget.initialResult!);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _shelfController.dispose();
    _signaturaController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _pagesController.dispose();
    _contributorsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyLookupResult(BookLookupResult result) {
    setState(() {
      _titleController.text = result.title;
      _authorController.text = result.author;
      if (result.isbn != null && result.isbn!.isNotEmpty) {
        _isbnController.text = result.isbn!;
      }
      _coverUrl = result.coverUrl;
      if (result.publisher != null) {
        _publisherController.text = result.publisher!;
      }
      if (result.publicationYear != null) {
        _yearController.text = result.publicationYear.toString();
      }
      if (result.pageCount != null) {
        _pagesController.text = result.pageCount.toString();
      }
      if (result.secondaryContributors != null) {
        _contributorsController.text = result.secondaryContributors!;
      }
      if (result.synopsis != null && _notesController.text.isEmpty) {
        _notesController.text = result.synopsis!;
      }
    });
  }

  Future<void> _lookupIsbn() async {
    final rawIsbn = _isbnController.text.trim();
    if (rawIsbn.isEmpty) return;

    setState(() => _isLookingUp = true);
    final result = await _isbnLookupService.lookupByIsbn(rawIsbn);
    if (!mounted) return;
    setState(() => _isLookingUp = false);

    if (result != null) {
      _applyLookupResult(result);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Found: ${result.title}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No book found for ISBN "$rawIsbn".')),
      );
    }
  }

  Future<void> _openOnlineSearch() async {
    final currentQuery = [
      _titleController.text.trim(),
      _authorController.text.trim(),
    ].where((t) => t.isNotEmpty).join(' ');

    final selected = await showDialog<BookLookupResult>(
      context: context,
      builder: (_) => BookSearchDialog(initialQuery: currentQuery),
    );

    if (selected != null && mounted) {
      _applyLookupResult(selected);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Populated: ${selected.title}')));
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final isbn = _isbnController.text.trim();
    final shelf = _shelfController.text.trim();
    final signatura = _signaturaController.text.trim();
    final publisher = _publisherController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    final pages = int.tryParse(_pagesController.text.trim());
    final contributors = _contributorsController.text.trim();
    final notes = _notesController.text.trim();

    if (isbn.isNotEmpty && _coverUrl != null && _coverUrl!.isNotEmpty) {
      await widget.coverCacheService.downloadAndCacheCover(
        rawIsbn: isbn,
        remoteUrl: _coverUrl!,
      );
    }

    final internalId = BookIdentifier.generate(title: title);

    await widget.database
        .into(widget.database.books)
        .insert(
          BooksCompanion.insert(
            title: title,
            author: author,
            internalId: drift.Value(internalId),
            isbn: drift.Value(isbn.isEmpty ? null : isbn),
            shelfLocation: drift.Value(shelf.isEmpty ? null : shelf),
            signatura: drift.Value(signatura.isEmpty ? null : signatura),
            publisher: drift.Value(publisher.isEmpty ? null : publisher),
            publicationYear: drift.Value(year),
            pageCount: drift.Value(pages),
            bindingType: drift.Value(_bindingType),
            secondaryContributors: drift.Value(
              contributors.isEmpty ? null : contributors,
            ),
            privateNotes: drift.Value(notes.isEmpty ? null : notes),
            readingStatus: drift.Value(_readingStatus),
            coverUrl: drift.Value(_coverUrl),
          ),
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Book'),
              TextButton.icon(
                onPressed: _openOnlineSearch,
                icon: const Icon(Icons.travel_explore, size: 18),
                label: const Text('Search Online'),
              ),
            ],
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Core & Shelf'),
              Tab(text: 'Bibliographic'),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        height: 460,
        child: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Core & Shelf
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _isbnController,
                            decoration: const InputDecoration(
                              labelText: 'ISBN',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: _isLookingUp ? null : _lookupIsbn,
                          tooltip: 'Query ISBN',
                          icon: _isLookingUp
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(
                        labelText: 'Author(s) *',
                        hintText:
                            'e.g. Karel Čapek or Terry Pratchett, Neil Gaiman',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _shelfController,
                            decoration: const InputDecoration(
                              labelText: 'Shelf Location',
                              hintText: 'e.g. Box 1',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _signaturaController,
                            decoration: const InputDecoration(
                              labelText: 'Signatura (Call #)',
                              hintText: 'e.g. CZ-HIST-01',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'unread', label: Text('To Read')),
                        ButtonSegment(value: 'reading', label: Text('Reading')),
                        ButtonSegment(value: 'read', label: Text('Finished')),
                      ],
                      selected: {_readingStatus},
                      onSelectionChanged: (s) =>
                          setState(() => _readingStatus = s.first),
                    ),
                  ],
                ),
              ),

              // TAB 2: Bibliographic
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _publisherController,
                            decoration: const InputDecoration(
                              labelText: 'Publisher',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            controller: _yearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Year',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            controller: _pagesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Pages',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _bindingType,
                            decoration: const InputDecoration(
                              labelText: 'Binding',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'paperback',
                                child: Text('Paperback (Brožovaná)'),
                              ),
                              DropdownMenuItem(
                                value: 'hardcover',
                                child: Text('Hardcover (Vázaná)'),
                              ),
                              DropdownMenuItem(
                                value: 'special',
                                child: Text('Special / Leather / Box'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _bindingType = v ?? 'paperback'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contributorsController,
                      decoration: const InputDecoration(
                        labelText:
                            'Secondary Contributors (Translators, Editors)',
                        hintText: 'e.g. Paul Selver (překladatel)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Private Notes / Synopsis',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _saveBook, child: const Text('Save Book')),
      ],
    );
  }
}
