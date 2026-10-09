import 'package:flutter/material.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/pages/book_catalog_page.dart';
import 'package:kittylogued/pages/placeholder_page.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';
import 'package:kittylogued/widgets/add_book_dialog.dart';
import 'package:kittylogued/widgets/add_book_menu.dart';
import 'package:kittylogued/widgets/app_bottom_bar.dart';
import 'package:kittylogued/widgets/barcode_scanner_dialog.dart';
import 'package:kittylogued/widgets/book_search_dialog.dart';
import 'package:kittylogued/widgets/isbn_entry_dialog.dart';

/// Root screen: hosts the pages, the bottom bar and the "add book" menu.
class MainShell extends StatefulWidget {
  final AppDatabase database;
  final CoverCacheService coverCacheService;

  const MainShell({
    super.key,
    required this.database,
    required this.coverCacheService,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _catalogueIndex = 2;

  int _index = _catalogueIndex; // start on the catalogue, like before
  bool _menuOpen = false;

  void _toggleMenu() => setState(() => _menuOpen = !_menuOpen);
  void _closeMenu() {
    if (_menuOpen) setState(() => _menuOpen = false);
  }

  void _openAddDialog({String? initialIsbn, BookLookupResult? initialResult}) {
    setState(() => _index = _catalogueIndex);
    showDialog(
      context: context,
      builder: (_) => AddBookDialog(
        database: widget.database,
        coverCacheService: widget.coverCacheService,
        initialIsbn: initialIsbn,
        initialResult: initialResult,
      ),
    );
  }

  Future<void> _startScan() async {
    _closeMenu();
    final isbn = await showDialog<String>(
      context: context,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (isbn != null && mounted) _openAddDialog(initialIsbn: isbn);
  }

  Future<void> _startIsbnLookup() async {
    _closeMenu();
    final isbn = await showDialog<String>(
      context: context,
      builder: (_) => const IsbnEntryDialog(),
    );
    if (isbn != null && mounted) _openAddDialog(initialIsbn: isbn);
  }

  Future<void> _startTitleSearch() async {
    _closeMenu();
    final result = await showDialog<BookLookupResult>(
      context: context,
      builder: (_) => const BookSearchDialog(),
    );
    if (result != null && mounted) _openAddDialog(initialResult: result);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_menuOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeMenu();
      },
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _index,
              children: [
                const PlaceholderPage(title: 'Home', icon: Icons.home),
                const PlaceholderPage(
                  title: 'Lending / Borrowing',
                  icon: Icons.swap_horiz,
                ),
                BookCatalogPage(
                  database: widget.database,
                  coverCacheService: widget.coverCacheService,
                ),
                const PlaceholderPage(
                  title: 'Personal Account',
                  icon: Icons.person,
                ),
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
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
    );
  }
}
