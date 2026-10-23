import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/models/book_draft.dart';
import 'package:kittylogued/pages/book_search_page.dart';
import 'package:kittylogued/repositories/library_repository.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';
import 'package:kittylogued/utils/reading_progress.dart';
import 'package:kittylogued/widgets/barcode_scanner_dialog.dart';
import 'package:kittylogued/widgets/reading_progress_field.dart';
import 'package:kittylogued/widgets/star_rating.dart';
import 'package:kittylogued/widgets/tag_editor.dart';

/// Opens the full-screen form for adding a new book, or editing [book].
Future<void> openBookForm(
  BuildContext context, {
  required AppDatabase database,
  required LibraryRepository repository,
  required CoverCacheService coverCacheService,
  Book? book,
  String? initialIsbn,
  BookLookupResult? initialResult,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => BookFormPage(
        database: database,
        repository: repository,
        coverCacheService: coverCacheService,
        book: book,
        initialIsbn: initialIsbn,
        initialResult: initialResult,
      ),
    ),
  );
}

/// One screen for adding and editing a book (replaces the old dialogs).
class BookFormPage extends StatefulWidget {
  final AppDatabase database;
  final LibraryRepository repository;
  final CoverCacheService coverCacheService;
  final Book? book;
  final String? initialIsbn;
  final BookLookupResult? initialResult;

  const BookFormPage({
    super.key,
    required this.database,
    required this.repository,
    required this.coverCacheService,
    this.book,
    this.initialIsbn,
    this.initialResult,
  });

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _author = TextEditingController();
  final _isbn = TextEditingController();
  final _shelf = TextEditingController();
  final _signatura = TextEditingController();
  final _publisher = TextEditingController();
  final _year = TextEditingController();
  final _pages = TextEditingController();
  final _contributors = TextEditingController();
  final _synopsis = TextEditingController();
  final _notes = TextEditingController();
  final _review = TextEditingController();

  final _lookupService = IsbnLookupService();

  bool get _isEdit => widget.book != null;
  bool _isLookingUp = false;
  bool _dirty = false;
  bool _suppressDirty = false;

  String? _coverUrl;
  String _bindingType = 'paperback';

  String _readingStatus = 'unread';
  int _currentPage = 0;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  DateTime _progressDate = _today();
  bool _progressChanged = false;
  bool _progressDateChanged = false;
  List<ReadingLogDraft> _logs = [];

  int? _rating;
  List<TagDraft> _tags = [];

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<TextEditingController> get _controllers => [
    _title,
    _author,
    _isbn,
    _shelf,
    _signatura,
    _publisher,
    _year,
    _pages,
    _contributors,
    _synopsis,
    _notes,
    _review,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final book = widget.book;
    if (book != null) {
      _title.text = book.title;
      _author.text = book.author;
      _isbn.text = book.isbn ?? '';
      _shelf.text = book.shelfLocation ?? '';
      _signatura.text = book.signatura ?? '';
      _publisher.text = book.publisher ?? '';
      _year.text = book.publicationYear?.toString() ?? '';
      _pages.text = book.pageCount?.toString() ?? '';
      _contributors.text = book.secondaryContributors ?? '';
      _synopsis.text = book.synopsis ?? '';
      _notes.text = book.privateNotes ?? '';
      _review.text = book.reviewText ?? '';
      _coverUrl = book.coverUrl;
      _bindingType = book.bindingType ?? 'paperback';
      _readingStatus = book.readingStatus;
      _currentPage = book.currentPage;
      _startedAt = book.startedAt;
      _finishedAt = book.finishedAt;
      _rating = book.ratingHalfStars;
      widget.database.tagsForBook(book.id).then((tags) {
        if (mounted) setState(() => _tags = tags);
      });
      widget.database.logsForBook(book.id).then((logs) {
        if (mounted) setState(() => _logs = logs);
      });
    }

    if (widget.initialIsbn != null && widget.initialIsbn!.isNotEmpty) {
      _isbn.text = widget.initialIsbn!;
    }

    // Start tracking changes only after the fields were filled in.
    for (final c in _controllers) {
      c.addListener(_markDirty);
    }

    if (widget.initialIsbn != null && widget.initialIsbn!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _lookupIsbn(initialLookup: true),
      );
    }
    if (widget.initialResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _applyLookupResult(widget.initialResult!, markDirty: false);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (!_suppressDirty && !_dirty && mounted) {
      setState(() => _dirty = true);
    }
  }

  // ---------------------------------------------------------------------
  // Lookup
  // ---------------------------------------------------------------------

  void _applyLookupResult(BookLookupResult result, {bool markDirty = true}) {
    _suppressDirty = true;
    setState(() {
      _title.text = result.title;
      _author.text = result.author;
      if (result.isbn != null && result.isbn!.isNotEmpty) {
        _isbn.text = result.isbn!;
      }
      _coverUrl = result.coverUrl;
      if (result.publisher != null) _publisher.text = result.publisher!;
      if (result.publicationYear != null) {
        _year.text = result.publicationYear.toString();
      }
      if (result.pageCount != null) _pages.text = result.pageCount.toString();
      if (result.secondaryContributors != null) {
        _contributors.text = result.secondaryContributors!;
      }
      if (result.synopsis != null && _synopsis.text.isEmpty) {
        _synopsis.text = result.synopsis!;
      }
    });
    _suppressDirty = false;
    if (markDirty) _markDirty();
  }

  Future<void> _lookupIsbn({bool initialLookup = false}) async {
    final raw = _isbn.text.trim();
    if (raw.isEmpty) return;

    setState(() => _isLookingUp = true);
    final result = await _lookupService.lookupByIsbn(raw);
    if (!mounted) return;
    setState(() => _isLookingUp = false);

    final messenger = ScaffoldMessenger.of(context);
    if (result != null) {
      _applyLookupResult(result, markDirty: !initialLookup);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Updated metadata for: ${result.title}'
                : 'Found: ${result.title}',
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text('No book found for ISBN "$raw".')),
      );
    }
  }

  Future<void> _scanIsbn() async {
    final scanned = await showDialog<String>(
      context: context,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (scanned != null && mounted) {
      _isbn.text = scanned;
      _lookupIsbn();
    }
  }

  Future<void> _openOnlineSearch() async {
    final query = [
      _title.text.trim(),
      _author.text.trim(),
    ].where((t) => t.isNotEmpty).join(' ');

    final selected = await Navigator.of(context).push<BookLookupResult>(
      MaterialPageRoute<BookLookupResult>(
        builder: (_) =>
            BookSearchPage(database: widget.database, initialQuery: query),
      ),
    );
    if (selected != null && mounted) {
      _applyLookupResult(selected);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Populated: ${selected.title}')));
    }
  }

  // ---------------------------------------------------------------------
  // Reading progress and dates (all of it can be backdated)
  // ---------------------------------------------------------------------

  void _onProgress(String status, int page, {DateTime? on}) {
    setState(() {
      _readingStatus = status;
      _currentPage = page;
      if (on != null) {
        _progressDate = DateTime(on.year, on.month, on.day);
      }
      final dates = ReadingProgress.datesFor(
        status: status,
        startedAt: _startedAt,
        finishedAt: _finishedAt,
        now: on ?? _progressDate,
      );
      _startedAt = dates.startedAt;
      _finishedAt = dates.finishedAt;
      _progressChanged = true;
      _dirty = true;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<DateTime?> _pickDate(DateTime? initial) {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
  }

  Future<void> _addPastEntry() async {
    final total = int.tryParse(_pages.text.trim());
    final pageController = TextEditingController();
    var date = _progressDate;

    final entry = await showDialog<ReadingLogDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Add milestone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pageController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Page reached',
                  helperText: total != null ? 'of $total pages' : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(_fmt(date)),
                onPressed: () async {
                  final picked = await _pickDate(date);
                  if (picked != null) setLocal(() => date = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final page = int.tryParse(pageController.text.trim());
                if (page == null || page <= 0) return;
                Navigator.of(dialogContext).pop(
                  ReadingLogDraft(date, ReadingProgress.clampPage(page, total)),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    pageController.dispose();

    if (entry == null || !mounted) return;
    setState(() {
      _logs = [
        ..._logs.where((log) => !_isSameDay(log.date, entry.date)),
        entry,
      ];
      _dirty = true;
    });
    // A newer, further entry also moves the current progress.
    if (entry.page > _currentPage) {
      _onProgress(
        ReadingProgress.statusForPage(entry.page, total),
        entry.page,
        on: entry.date,
      );
    }
  }

  // ---------------------------------------------------------------------
  // Saving
  // ---------------------------------------------------------------------

  String? _n(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _author.text.trim().isEmpty) {
      _tabController.animateTo(0);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _formKey.currentState?.validate(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and author are required.')),
      );
      return;
    }

    final pages = int.tryParse(_pages.text.trim());
    final page = ReadingProgress.clampPage(_currentPage, pages);

    // Progress that was typed in becomes a dated entry, unless one for that
    // date already exists. Replacing the date's entry is important when a page
    // correction subtracts progress; retaining the previous larger page would
    // keep that date incorrectly counted as a streak day.
    final logs = [..._logs];
    if (_progressChanged || _progressDateChanged) {
      logs.removeWhere((log) => _isSameDay(log.date, _progressDate));
      if (page > 0) logs.add(ReadingLogDraft(_progressDate, page));
    }

    final isbn = _n(_isbn);
    if (isbn != null && _coverUrl != null && _coverUrl!.isNotEmpty) {
      await widget.coverCacheService.downloadAndCacheCover(
        rawIsbn: isbn,
        remoteUrl: _coverUrl!,
      );
    }

    final draft = BookDraft(
      title: _title.text.trim(),
      author: _author.text.trim(),
      isbn: isbn,
      publisher: _n(_publisher),
      publicationYear: int.tryParse(_year.text.trim()),
      pageCount: pages,
      bindingType: _bindingType,
      secondaryContributors: _n(_contributors),
      coverUrl: _coverUrl,
      synopsis: _n(_synopsis),
      shelfLocation: _n(_shelf),
      signatura: _n(_signatura),
      readingStatus: _readingStatus,
      currentPage: page,
      startedAt: _startedAt,
      finishedAt: _finishedAt,
      logs: logs,
      ratingHalfStars: _rating,
      reviewText: _n(_review),
      privateNotes: _n(_notes),
      tags: _tags,
    );

    if (!_isEdit && isbn != null) {
      final existing = await widget.repository.findByIsbn(isbn);
      if (!mounted) return;
      if (existing != null) {
        final openExisting = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Already in your library'),
            content: Text(
              '"${existing.title}" is already saved. Open it to update '
              'reading progress or edit its details instead?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Keep editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Open existing book'),
              ),
            ],
          ),
        );
        if (openExisting == true && mounted) {
          await openBookForm(
            context,
            database: widget.database,
            repository: widget.repository,
            coverCacheService: widget.coverCacheService,
            book: existing,
          );
          if (mounted) Navigator.of(context).pop();
        }
        return;
      }
    }

    if (_isEdit) {
      await widget.repository.updateBook(widget.book!.id, draft);
    } else {
      await widget.repository.addBook(draft);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDiscard() async {
    final action = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('You have unsaved changes'),
        content: const Text(
          'Save your book, keep editing, or discard the changes you made.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(0),
            child: const Text('Keep editing'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(1),
            child: const Text('Discard changes'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(2),
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 1) {
      Navigator.of(context).pop();
    } else if (action == 2) {
      await _save();
    }
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: const OutlineInputBorder(),
  );

  Widget _tabScroll(List<Widget> children) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(padding: const EdgeInsets.all(16), children: children),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String text, {String? note}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.titleSmall),
          if (note != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                note,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bookTab() {
    return _tabScroll([
      Row(
        children: [
          Expanded(
            child: TextFormField(controller: _isbn, decoration: _dec('ISBN')),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: _scanIsbn,
            tooltip: 'Scan barcode',
            icon: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            onPressed: _isLookingUp ? null : _lookupIsbn,
            tooltip: 'Look up ISBN',
            icon: _isLookingUp
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _title,
        decoration: _dec('Title *'),
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _author,
        decoration: _dec(
          'Author(s) *',
          hint: 'e.g. Karel Čapek or Terry Pratchett, Neil Gaiman',
        ),
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _shelf,
              decoration: _dec('Shelf Location', hint: 'e.g. Box 1'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _signatura,
              decoration: _dec('Signatura (Call #)', hint: 'e.g. CZ-HIST-01'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _publisher,
              decoration: _dec('Publisher'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: TextFormField(
              controller: _year,
              keyboardType: TextInputType.number,
              decoration: _dec('Year'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          SizedBox(
            width: 110,
            child: ListenableBuilder(
              listenable: _pages,
              builder: (context, _) {
                final missing = _pages.text.trim().isEmpty;
                final amber = Theme.of(context).colorScheme.tertiary;
                return TextFormField(
                  controller: _pages,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Pages',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: missing ? amber : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: missing ? amber : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: missing
                            ? amber
                            : Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _bindingType,
              decoration: _dec('Binding'),
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
              onChanged: (v) => setState(() {
                _bindingType = v ?? 'paperback';
                _dirty = true;
              }),
            ),
          ),
        ],
      ),
      ListenableBuilder(
        listenable: _pages,
        builder: (context, _) => _pages.text.trim().isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Missing from catalogue — enter the page count if known.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 12,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _contributors,
        decoration: _dec(
          'Secondary Contributors (Translators, Editors)',
          hint: 'e.g. Paul Selver (překladatel)',
        ),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _synopsis,
        maxLines: 4,
        decoration: _dec('Synopsis / description'),
      ),
    ]);
  }

  Widget _dateTile(
    String label,
    DateTime? value,
    ValueChanged<DateTime?> onChanged,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event, size: 20),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value == null ? 'Not set' : _fmt(value)),
          if (value != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              tooltip: 'Clear',
              onPressed: () => setState(() {
                onChanged(null);
                _dirty = true;
              }),
            ),
        ],
      ),
      onTap: () async {
        final picked = await _pickDate(value);
        if (picked != null) {
          setState(() {
            onChanged(picked);
            _dirty = true;
          });
        }
      },
    );
  }

  Future<void> _pickProgressDate() async {
    final picked = await _pickDate(_progressDate);
    if (picked != null) {
      setState(() {
        _progressDate = picked;
        _progressDateChanged = true;
        _dirty = true;
      });
    }
  }

  Widget _readingTab() {
    final sortedLogs = [..._logs]..sort((a, b) => b.date.compareTo(a.date));
    final isToday = _progressDate == _today();
    final datesSummary =
        'Started ${_startedAt == null ? '-' : _fmt(_startedAt!)}  •  '
        'Finished ${_finishedAt == null ? '-' : _fmt(_finishedAt!)}';

    return _tabScroll([
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListenableBuilder(
                listenable: _pages,
                builder: (context, _) => ReadingProgressField(
                  status: _readingStatus,
                  currentPage: _currentPage,
                  totalPages: int.tryParse(_pages.text.trim()),
                  onChanged: (status, page) => _onProgress(status, page),
                ),
              ),
              const Divider(height: 24),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: _pickProgressDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    isToday
                        ? 'Reading date: Today'
                        : 'Reading date: ${_fmt(_progressDate)}',
                  ),
                ),
              ),
              if (sortedLogs.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Recent reading',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                for (final entry in sortedLogs.take(3))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${_fmt(entry.date)}: page ${entry.page}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Log progress and save'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
      _sectionHeader(
        Icons.flag_outlined,
        'Milestones',
        note: 'Earlier points in your reading',
      ),
      if (sortedLogs.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'No milestones yet. Pages you save show up here.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      for (final entry in sortedLogs)
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.bookmark_outline, size: 20),
          title: Text('Page ${entry.page}'),
          subtitle: Text(_fmt(entry.date)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Remove milestone',
            onPressed: () => setState(() {
              _logs = _logs.where((l) => !identical(l, entry)).toList();
              _dirty = true;
            }),
          ),
        ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: _addPastEntry,
          icon: const Icon(Icons.add),
          label: const Text('Add milestone'),
        ),
      ),
      const SizedBox(height: 8),
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: const Text('Dates'),
        subtitle: Text(
          datesSummary,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        children: [
          _dateTile('Started on', _startedAt, (d) => _startedAt = d),
          _dateTile('Finished on', _finishedAt, (d) => _finishedAt = d),
        ],
      ),
    ]);
  }

  Widget _notesTab() {
    return _tabScroll([
      _sectionHeader(
        Icons.public,
        'Public',
        note: 'Rating and comment can be seen by others once sharing is on.',
      ),
      Row(
        children: [
          StarRating(
            value: _rating,
            size: 38,
            onChanged: (v) => setState(() {
              _rating = v;
              _dirty = true;
            }),
          ),
          const SizedBox(width: 12),
          Text(
            StarRating.label(_rating),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (_rating != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear rating',
              onPressed: () => setState(() {
                _rating = null;
                _dirty = true;
              }),
            ),
        ],
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _review,
        maxLines: 5,
        decoration: _dec('Your comment', hint: 'What did you think of it?'),
      ),
      _sectionHeader(
        Icons.lock_outline,
        'Private',
        note: 'Stays on this device.',
      ),
      TextFormField(
        controller: _notes,
        maxLines: 5,
        decoration: _dec('Private notes'),
      ),
      const SizedBox(height: 16),
      TagEditor(
        database: widget.database,
        tags: _tags,
        onChanged: (tags) => setState(() {
          _tags = tags;
          _dirty = true;
        }),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Edit book' : 'Add book'),
          actions: [
            IconButton(
              icon: const Icon(Icons.travel_explore),
              tooltip: 'Search online',
              onPressed: _openOnlineSearch,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Book'),
              Tab(text: 'Reading'),
              Tab(text: 'Rating & notes'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [_bookTab(), _readingTab(), _notesTab()],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(_isEdit ? 'Save changes' : 'Save book'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ),
    );
  }
}
