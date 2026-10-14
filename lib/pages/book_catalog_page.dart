import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/services/saved_views_store.dart';
import 'package:kittylogued/utils/reading_progress.dart';
import 'package:kittylogued/utils/text_normalizer.dart';
import 'package:kittylogued/widgets/book_cover_thumbnail.dart';
import 'package:kittylogued/widgets/cover_viewer.dart';
import 'package:kittylogued/pages/book_form_page.dart';
import 'package:kittylogued/pages/book_detail_page.dart';
import 'package:kittylogued/widgets/book_detail_pane.dart';
import 'package:kittylogued/widgets/lending_dialogs.dart';
import 'package:kittylogued/widgets/quick_update_sheet.dart';
import 'package:kittylogued/widgets/star_rating.dart';
import 'package:kittylogued/widgets/reading_progress_bar.dart';

class BookCatalogPage extends StatefulWidget {
  const BookCatalogPage({super.key});

  @override
  State<BookCatalogPage> createState() => _BookCatalogPageState();
}

class _BookCatalogPageState extends State<BookCatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedShelf = 'all';
  final Set<String> _selectedTags = <String>{};
  AppServices get _s => AppScope.of(context);
  String _sortKey = 'title';
  bool _sortAscending = true;
  int? _selectedBookId;
  final Map<int, (String, String)> _searchIndex = {};
  late final ValueNotifier<int> _focusRequests;
  Map<int, Loan> _loansByBook = {};
  StreamSubscription<List<LoanEntry>>? _loanSub;
  Map<int, List<Tag>> _tagsByBook = {};
  StreamSubscription<Map<int, List<Tag>>>? _tagSub;

  @override
  void initState() {
    super.initState();
    final services = AppScope.of(context);
    _tagSub = services.database.watchTagsByBook().listen((map) {
      if (mounted) setState(() => _tagsByBook = map);
    });
    _loanSub = services.database.watchLoanEntries().listen((entries) {
      if (!mounted) return;
      setState(() {
        _loansByBook = {
          for (final e in entries)
            if (e.loan.direction == 'lent' &&
                e.loan.status == 'active' &&
                e.loan.bookId != null)
              e.loan.bookId!: e.loan,
        };
      });
    });
    _focusRequests = services.focusSearchRequests;
    _focusRequests.addListener(_onFocusRequest);
  }

  void _onFocusRequest() {
    if (mounted) _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusRequests.removeListener(_onFocusRequest);
    _tagSub?.cancel();
    _loanSub?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openEditBookDialog(BuildContext context, Book book) {
    openBookForm(
      context,
      database: _s.database,
      repository: _s.repository,
      coverCacheService: _s.coverCache,
      book: book,
    );
  }

  Future<void> _deleteBook(BuildContext context, Book book) async {
    final messenger = ScaffoldMessenger.of(context);
    final repository = _s.repository;
    await repository.softDelete(book.id);
    if (_selectedBookId == book.id && mounted) {
      setState(() => _selectedBookId = null);
    }
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Deleted "${book.title}"'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repository.restore(book.id),
        ),
      ),
    );
  }

  Future<void> _markRead(BuildContext context, Book book) async {
    final messenger = ScaffoldMessenger.of(context);
    await _s.repository.markRead(book);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Marked "${book.title}" as finished'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openQuickUpdate(BuildContext context, Book book) {
    showQuickUpdateSheet(context, book: book, repository: _s.repository);
  }

  Widget _swipeBackground(
    Alignment alignment,
    Color color,
    IconData icon,
    String label,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= 980;

  /// On wide windows: list on the left, details of the selected book on the right.
  Widget _withDetailPane(BuildContext context, Widget list, List<Book> books) {
    if (!_isWide(context)) return list;
    Book? found;
    for (final b in books) {
      if (b.id == _selectedBookId) {
        found = b;
        break;
      }
    }
    final selected = found;
    return Row(
      children: [
        Expanded(child: list),
        const VerticalDivider(width: 1),
        SizedBox(
          width: 420,
          child: selected == null
              ? const Center(
                  child: Text(
                    'Select a book to see its details.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : BookDetailPane(
                  key: ValueKey(selected.id),
                  book: selected,
                  tags: _tagsByBook[selected.id] ?? const <Tag>[],
                  coverCache: _s.coverCache,
                  onEdit: () => _openEditBookDialog(context, selected),
                  loan: _loansByBook[selected.id],
                  onQuickUpdate: () => _openQuickUpdate(context, selected),
                  onLendOrReturn: () => lendOrReturnBook(
                    context,
                    selected,
                    _loansByBook[selected.id],
                  ),
                ),
        ),
      ],
    );
  }

  // ---- sorting, search index, saved views ----

  static const Map<String, String> _sortLabels = {
    'title': 'Title',
    'author': 'Author',
    'added': 'Date added',
    'rating': 'Rating',
    'progress': 'Progress',
  };

  double _progressOf(Book b) =>
      ReadingProgress.fraction(b.readingStatus, b.currentPage, b.pageCount);

  int _compareBooks(Book a, Book b) {
    int c;
    switch (_sortKey) {
      case 'author':
        c = normalizeText(a.author).compareTo(normalizeText(b.author));
        break;
      case 'added':
        c = a.createdAt.compareTo(b.createdAt);
        break;
      case 'rating':
        c = (a.ratingHalfStars ?? -1).compareTo(b.ratingHalfStars ?? -1);
        break;
      case 'progress':
        c = _progressOf(a).compareTo(_progressOf(b));
        break;
      default:
        c = normalizeText(a.title).compareTo(normalizeText(b.title));
    }
    if (c == 0) c = normalizeText(a.title).compareTo(normalizeText(b.title));
    return _sortAscending ? c : -c;
  }

  /// Searchable text of a book (title, author, ISBN, shelf, notes, comment,
  /// tags ...), normalised once and remembered until the book changes.
  String _searchText(Book book) {
    final tagNames = (_tagsByBook[book.id] ?? const <Tag>[])
        .map((t) => t.name)
        .join(' ');
    final signature = '${book.updatedAt?.millisecondsSinceEpoch}|$tagNames';
    final cached = _searchIndex[book.id];
    if (cached != null && cached.$1 == signature) return cached.$2;
    final text = normalizeText(
      '${book.title} ${book.author} ${book.isbn ?? ""} '
      '${book.signatura ?? ""} ${book.publisher ?? ""} '
      '${book.secondaryContributors ?? ""} ${book.shelfLocation ?? ""} '
      '${book.synopsis ?? ""} ${book.privateNotes ?? ""} '
      '${book.reviewText ?? ""} $tagNames',
    );
    _searchIndex[book.id] = (signature, text);
    return text;
  }

  void _applyView(SavedView view) {
    _selectedStatus = view.status;
    _selectedShelf = view.shelf;
    _selectedTags
      ..clear()
      ..addAll(view.tags);
    _sortKey = view.sortKey;
    _sortAscending = view.ascending;
  }

  Future<void> _saveCurrentView(BuildContext sheetContext) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save view'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Unread on Box 1',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(dialogContext).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await _s.savedViews.save(
      SavedView(
        name: name,
        status: _selectedStatus,
        shelf: _selectedShelf,
        tags: _selectedTags.toList(),
        sortKey: _sortKey,
        ascending: _sortAscending,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedStatus = 'all';
      _selectedShelf = 'all';
      _selectedTags.clear();
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

  Widget _buildTagChip(Tag tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tag.isPublic ? Icons.public : Icons.lock_outline,
            size: 10,
            color: Colors.grey,
          ),
          const SizedBox(width: 3),
          Text(
            tag.name,
            style: const TextStyle(fontSize: 10.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Small progress bar shown in the title row, between name and edit button.
  Widget _buildTitleProgress(Book book, {double width = 52}) {
    final total = book.pageCount;
    final status = book.readingStatus;
    if (status == 'reading' && (total ?? 0) <= 0) {
      return const SizedBox.shrink();
    }
    final fraction = ReadingProgress.fraction(status, book.currentPage, total);
    final bar = ReadingProgressBar(
      status: status,
      fraction: fraction,
      width: width,
      height: 5,
    );
    if (total == null || total <= 0) return bar;
    final shown = status == 'read' ? total : book.currentPage;
    return Tooltip(message: '$shown / $total pages', child: bar);
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _openDetail(BuildContext context, Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookDetailPage(bookId: book.id)),
    );
  }

  /// Edit and delete side by side on top, the lend button underneath.
  Widget _buildTrailing(BuildContext context, Book book, Loan? loan) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit book',
          onPressed: () => _openEditBookDialog(context, book),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          tooltip: 'Delete book',
          onPressed: () => _deleteBook(context, book),
        ),
        TextButton.icon(
          onPressed: () => lendOrReturnBook(context, book, loan),
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: Text(loan == null ? 'Lend' : 'Return'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }

  /// One small menu instead of two icon buttons on narrow tiles.
  Widget _buildCompactMenu(BuildContext context, Book book, Loan? loan) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _openEditBookDialog(context, book);
            break;
          case 'quick':
            _openQuickUpdate(context, book);
            break;
          case 'lend':
            lendOrReturnBook(context, book, loan);
            break;
          case 'delete':
            _deleteBook(context, book);
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
          ),
        ),
        PopupMenuItem(
          value: 'quick',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.bolt),
            title: Text('Quick update'),
          ),
        ),
        PopupMenuItem(
          value: 'lend',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.swap_horiz),
            title: Text(loan == null ? 'Lend' : 'Mark returned'),
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline, color: Colors.redAccent),
            title: Text('Delete'),
          ),
        ),
      ],
    );
  }

  int get _activeFilterCount =>
      (_selectedStatus != 'all' ? 1 : 0) +
      (_selectedShelf != 'all' ? 1 : 0) +
      _selectedTags.length;

  /// One tile next to the search bar that opens all filters.
  Widget _buildFilterTile() {
    final count = _activeFilterCount;
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      child: IconButton.filledTonal(
        icon: const Icon(Icons.tune),
        tooltip: 'Filters',
        onPressed: _openFilterSheet,
        style: IconButton.styleFrom(
          minimumSize: const Size(56, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _filterSection(String title, IconData icon, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  /// Bottom sheet: sorting, saved views and the three filters (holding
  /// place, status, tags).
  Future<void> _openFilterSheet() async {
    final books = await (_s.database.select(
      _s.database.books,
    )..where((b) => b.deletedAt.isNull())).get();
    final shelves = <String>{
      for (final b in books)
        if (b.shelfLocation != null && b.shelfLocation!.trim().isNotEmpty)
          b.shelfLocation!.trim(),
    }.toList()..sort();
    final tagNames =
        _tagsByBook.values
            .expand((list) => list.map((tag) => tag.name))
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) {
          void update(VoidCallback change) {
            setState(change);
            setSheet(() {});
          }

          const statuses = {
            'all': 'All',
            'unread': 'To Read',
            'reading': 'Reading',
            'read': 'Finished',
          };

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filters',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: _activeFilterCount == 0
                            ? null
                            : () => update(() {
                                _selectedStatus = 'all';
                                _selectedShelf = 'all';
                                _selectedTags.clear();
                              }),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  _filterSection(
                    'Sort by',
                    Icons.sort,
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final entry in _sortLabels.entries)
                          ChoiceChip(
                            label: Text(entry.value),
                            selected: _sortKey == entry.key,
                            onSelected: (_) => update(() {
                              _sortKey = entry.key;
                              _sortAscending =
                                  entry.key == 'title' || entry.key == 'author';
                            }),
                          ),
                        ActionChip(
                          avatar: Icon(
                            _sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                          label: Text(
                            _sortAscending ? 'Ascending' : 'Descending',
                          ),
                          onPressed: () =>
                              update(() => _sortAscending = !_sortAscending),
                        ),
                      ],
                    ),
                  ),
                  _filterSection(
                    'Saved views',
                    Icons.bookmarks_outlined,
                    ListenableBuilder(
                      listenable: _s.savedViews,
                      builder: (context, _) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (final view in _s.savedViews.views)
                              InputChip(
                                label: Text(view.name),
                                onPressed: () => update(() => _applyView(view)),
                                onDeleted: () =>
                                    _s.savedViews.remove(view.name),
                              ),
                            ActionChip(
                              avatar: const Icon(Icons.add, size: 16),
                              label: const Text('Save current view'),
                              onPressed: () => _saveCurrentView(sheetContext),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  _filterSection(
                    'Holding place',
                    Icons.shelves,
                    shelves.isEmpty
                        ? const Text(
                            'No shelf locations yet.',
                            style: TextStyle(color: Colors.grey),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              ChoiceChip(
                                label: const Text('All'),
                                selected: _selectedShelf == 'all',
                                onSelected: (_) =>
                                    update(() => _selectedShelf = 'all'),
                              ),
                              for (final shelf in shelves)
                                ChoiceChip(
                                  label: Text(shelf),
                                  selected: _selectedShelf == shelf,
                                  onSelected: (_) =>
                                      update(() => _selectedShelf = shelf),
                                ),
                            ],
                          ),
                  ),
                  _filterSection(
                    'Status',
                    Icons.bookmark_outline,
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final entry in statuses.entries)
                          ChoiceChip(
                            label: Text(entry.value),
                            selected: _selectedStatus == entry.key,
                            onSelected: (_) =>
                                update(() => _selectedStatus = entry.key),
                          ),
                      ],
                    ),
                  ),
                  _filterSection(
                    'Tags',
                    Icons.sell_outlined,
                    tagNames.isEmpty
                        ? const Text(
                            'No tags yet.',
                            style: TextStyle(color: Colors.grey),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              for (final name in tagNames)
                                FilterChip(
                                  label: Text(name),
                                  selected: _selectedTags.contains(name),
                                  onSelected: (selected) => update(() {
                                    if (selected) {
                                      _selectedTags.add(name);
                                    } else {
                                      _selectedTags.remove(name);
                                    }
                                  }),
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters =
        _searchQuery.isNotEmpty ||
        _selectedStatus != 'all' ||
        _selectedShelf != 'all' ||
        _selectedTags.isNotEmpty;

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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search title, author, ISBN, signatura, or publisher...',
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
                const SizedBox(width: 8),
                _buildFilterTile(),
              ],
            ),
          ),
          const Divider(height: 12),
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: _s.database.watchLiveBooks(),
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

                final queryTokens = normalizeText(_searchQuery)
                    .split(RegExp(r'\s+'))
                    .where((token) => token.isNotEmpty)
                    .toList();

                final filteredBooks = allBooks.where((book) {
                  if (queryTokens.isNotEmpty) {
                    final targetCombined = _searchText(book);
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

                  if (_selectedTags.isNotEmpty) {
                    final names = (_tagsByBook[book.id] ?? const <Tag>[])
                        .map((tag) => tag.name)
                        .toSet();
                    if (!_selectedTags.every(names.contains)) return false;
                  }

                  return true;
                }).toList()..sort(_compareBooks);

                final listColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                final loan = _loansByBook[book.id];

                                // Narrow tiles (phone in portrait) move the progress bar and
                                // status below the title and use a compact menu.
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final compact = constraints.maxWidth < 720;
                                    return Dismissible(
                                      key: ValueKey('book-${book.id}'),
                                      background: _swipeBackground(
                                        Alignment.centerLeft,
                                        Colors.green,
                                        Icons.check_circle_outline,
                                        'Mark finished',
                                      ),
                                      secondaryBackground: _swipeBackground(
                                        Alignment.centerRight,
                                        Colors.redAccent,
                                        Icons.delete_outline,
                                        'Delete',
                                      ),
                                      confirmDismiss: (direction) async {
                                        if (direction ==
                                            DismissDirection.startToEnd) {
                                          await _markRead(context, book);
                                        } else {
                                          await _deleteBook(context, book);
                                        }
                                        return false; // the list updates itself
                                      },
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onSecondaryTap: () =>
                                            _openQuickUpdate(context, book),
                                        child: Opacity(
                                          opacity: loan != null ? 0.5 : 1.0,
                                          child: Card(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                            child: ListTile(
                                              selected:
                                                  _isWide(context) &&
                                                  _selectedBookId == book.id,
                                              onTap: () => _isWide(context)
                                                  ? setState(
                                                      () => _selectedBookId =
                                                          book.id,
                                                    )
                                                  : _openDetail(context, book),
                                              onLongPress: () =>
                                                  _openQuickUpdate(
                                                    context,
                                                    book,
                                                  ),
                                              leading: GestureDetector(
                                                onTap: () => showCoverViewer(
                                                  context,
                                                  title: book.title,
                                                  isbn: book.isbn,
                                                  coverUrl: book.coverUrl,
                                                  cacheService: _s.coverCache,
                                                ),
                                                child: BookCoverThumbnail(
                                                  isbn: book.isbn,
                                                  coverUrl: book.coverUrl,
                                                  cacheService: _s.coverCache,
                                                ),
                                              ),
                                              title: compact
                                                  ? Text(
                                                      book.title,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            book.title,
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        _buildTitleProgress(
                                                          book,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        _buildStatusChip(
                                                          book.readingStatus,
                                                        ),
                                                      ],
                                                    ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${book.author}\nShelf: $shelf${hasSignatura ? "  •  Call #: ${book.signatura}" : ""}',
                                                    ),
                                                    if (loan != null)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.swap_horiz,
                                                              size: 14,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                'Lent to ${loan.personName} • since ${_fmtDate(loan.startedAt)}',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if (compact)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 6,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            _buildTitleProgress(
                                                              book,
                                                              width: 90,
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            _buildStatusChip(
                                                              book.readingStatus,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if (book.ratingHalfStars !=
                                                        null)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            StarRating(
                                                              value: book
                                                                  .ratingHalfStars,
                                                              size: 14,
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Text(
                                                              StarRating.label(
                                                                book.ratingHalfStars,
                                                              ),
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if ((_tagsByBook[book.id] ??
                                                            const <Tag>[])
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 6,
                                                            ),
                                                        child: Wrap(
                                                          spacing: 4,
                                                          runSpacing: 4,
                                                          children: [
                                                            for (final tag
                                                                in _tagsByBook[book
                                                                    .id]!)
                                                              _buildTagChip(
                                                                tag,
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              isThreeLine: true,
                                              trailing: compact
                                                  ? _buildCompactMenu(
                                                      context,
                                                      book,
                                                      loan,
                                                    )
                                                  : _buildTrailing(
                                                      context,
                                                      book,
                                                      loan,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );

                return _withDetailPane(context, listColumn, filteredBooks);
              },
            ),
          ),
        ],
      ),
    );
  }
}
