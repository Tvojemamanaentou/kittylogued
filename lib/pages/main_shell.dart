import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/pages/batch_isbn_page.dart';
import 'package:kittylogued/pages/batch_review_page.dart';
import 'package:kittylogued/pages/book_catalog_page.dart';
import 'package:kittylogued/pages/book_form_page.dart';
import 'package:kittylogued/pages/book_search_page.dart';
import 'package:kittylogued/pages/home_page.dart';
import 'package:kittylogued/pages/personal_page.dart';
import 'package:kittylogued/pages/placeholder_page.dart';
import 'package:kittylogued/services/batch_import_queue.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';
import 'package:kittylogued/widgets/add_book_menu.dart';
import 'package:kittylogued/widgets/app_bottom_bar.dart';
import 'package:kittylogued/widgets/barcode_scanner_dialog.dart';
import 'package:kittylogued/widgets/isbn_entry_dialog.dart';

/// Root screen: hosts the pages, the bottom bar and the "add book" menu.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _catalogueIndex = 2;

  int _index = _catalogueIndex; // start on the catalogue, like before
  bool _menuOpen = false;
  bool _batchMode = false;
  bool _announced = false;
  final DateTime _startedAt = DateTime.now();
  late final BatchImportQueue _queue;

  AppServices get _s => AppScope.of(context);

  @override
  void initState() {
    super.initState();
    _queue = AppScope.of(context).batchQueue;
    _queue.addListener(_announceSavedBatch);
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceSavedBatch());
  }

  @override
  void dispose() {
    _queue.removeListener(_announceSavedBatch);
    super.dispose();
  }

  /// Right after start-up: tell the user about books still waiting for review.
  void _announceSavedBatch() {
    if (_announced || !mounted) return;
    if (DateTime.now().difference(_startedAt) > const Duration(seconds: 8)) {
      _queue.removeListener(_announceSavedBatch);
      return;
    }
    final count = _queue.items.length;
    if (count == 0) return;
    _announced = true;
    _queue.removeListener(_announceSavedBatch);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count scanned book(s) are waiting for review'),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(label: 'Review', onPressed: _reviewBatch),
      ),
    );
  }

  void _toggleMenu() => setState(() => _menuOpen = !_menuOpen);
  void _closeMenu() {
    if (_menuOpen) setState(() => _menuOpen = false);
  }

  void _openAddDialog({String? initialIsbn, BookLookupResult? initialResult}) {
    setState(() => _index = _catalogueIndex);
    openBookForm(
      context,
      database: _s.database,
      repository: _s.repository,
      coverCacheService: _s.coverCache,
      initialIsbn: initialIsbn,
      initialResult: initialResult,
    );
  }

  /// Opens the editable overview of everything collected in batch mode.
  Future<void> _reviewBatch() async {
    final queue = _s.batchQueue;
    if (queue.items.isEmpty || !mounted) return;
    setState(() => _index = _catalogueIndex);
    final added = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (_) => BatchReviewPage(
          queue: queue,
          database: _s.database,
          repository: _s.repository,
          coverCacheService: _s.coverCache,
        ),
      ),
    );
    if (added != null && added > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $added book(s) to your library')),
      );
    }
  }

  Future<void> _startScan() async {
    _closeMenu();
    if (_batchMode) {
      await showDialog<void>(
        context: context,
        builder: (_) => BarcodeScannerDialog(onBatchIsbn: _s.batchQueue.add),
      );
      await _reviewBatch();
      return;
    }
    final isbn = await showDialog<String>(
      context: context,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (isbn != null && mounted) _openAddDialog(initialIsbn: isbn);
  }

  Future<void> _startIsbnLookup() async {
    _closeMenu();
    if (_batchMode) {
      final review = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => BatchIsbnPage(queue: _s.batchQueue),
        ),
      );
      if (review == true) await _reviewBatch();
      return;
    }
    final isbn = await showDialog<String>(
      context: context,
      builder: (_) => const IsbnEntryDialog(),
    );
    if (isbn != null && mounted) _openAddDialog(initialIsbn: isbn);
  }

  Future<void> _startTitleSearch() async {
    _closeMenu();
    final result = await Navigator.of(context).push<BookLookupResult>(
      MaterialPageRoute<BookLookupResult>(
        builder: (_) => const BookSearchPage(),
      ),
    );
    if (result != null && mounted) _openAddDialog(initialResult: result);
  }

  void _focusSearch() {
    setState(() => _index = _catalogueIndex);
    _s.focusSearchRequests.value++;
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        // Ctrl+N / Cmd+N: add a book. Ctrl+F / Cmd+F: search the catalogue.
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
            _openAddDialog(),
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
            _openAddDialog(),
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _focusSearch,
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
            _focusSearch,
      },
      child: Focus(
        autofocus: true,
        child: PopScope(
          canPop: !_menuOpen,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _closeMenu();
          },
          child: Scaffold(
            body: Stack(
              children: [
                IndexedStack(
                  index: _index,
                  children: const [
                    HomePage(),
                    PlaceholderPage(
                      title: 'Lending / Borrowing',
                      icon: Icons.swap_horiz,
                    ),
                    BookCatalogPage(),
                    PersonalPage(),
                  ],
                ),
                // Dimmed backdrop; tap to close the menu.
                IgnorePointer(
                  ignoring: !_menuOpen,
                  child: GestureDetector(
                    onTap: _closeMenu,
                    child: AnimatedOpacity(
                      opacity: _menuOpen ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const ColoredBox(
                        color: Colors.black54,
                        child: SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                AddBookBubbles(
                  isOpen: _menuOpen,
                  onScan: _startScan,
                  onIsbn: _startIsbnLookup,
                  onSearch: _startTitleSearch,
                  batchMode: _batchMode,
                  onBatchChanged: (v) => setState(() => _batchMode = v),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: AddBookFab(
              isOpen: _menuOpen,
              onPressed: _toggleMenu,
            ),
            bottomNavigationBar: AppBottomBar(
              selectedIndex: _index,
              onSelected: (i) {
                setState(() {
                  _index = i;
                  _menuOpen = false;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
