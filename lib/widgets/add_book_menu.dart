import 'package:flutter/material.dart';

/// The big round plus button that sits in the notch of the bottom bar.
/// Rotates into an "x" while the menu is open.
class AddBookFab extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onPressed;

  const AddBookFab({super.key, required this.isOpen, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      heroTag: 'add_book_fab',
      shape: const CircleBorder(),
      tooltip: 'Add new book',
      onPressed: onPressed,
      child: AnimatedRotation(
        turns: isOpen ? 0.125 : 0,
        duration: const Duration(milliseconds: 200),
        child: const Icon(Icons.add, size: 44),
      ),
    );
  }
}

/// The three small bubbles that fan out above the plus button:
/// barcode scanning, ISBN lookup and title/author search.
class AddBookBubbles extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onScan;
  final VoidCallback onIsbn;
  final VoidCallback onSearch;

  const AddBookBubbles({
    super.key,
    required this.isOpen,
    required this.onScan,
    required this.onIsbn,
    required this.onSearch,
  });

  Widget _bubble(
    BuildContext context, {
    required double dx,
    required double bottom,
    required String tooltip,
    required Widget child,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: Center(
        child: Transform.translate(
          offset: Offset(dx, 0),
          child: AnimatedScale(
            scale: isOpen ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: Tooltip(
              message: tooltip,
              child: Material(
                color: scheme.secondaryContainer,
                elevation: 4,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Center(child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onColor = Theme.of(context).colorScheme.onSecondaryContainer;
    return IgnorePointer(
      ignoring: !isOpen,
      child: Stack(
        children: [
          _bubble(
            context,
            dx: -92,
            bottom: 76,
            tooltip: 'Scan barcode',
            onTap: onScan,
            child: Icon(Icons.qr_code_scanner, color: onColor, size: 28),
          ),
          _bubble(
            context,
            dx: 0,
            bottom: 140,
            tooltip: 'ISBN lookup',
            onTap: onIsbn,
            child: Text(
              'ISBN',
              style: TextStyle(
                color: onColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          _bubble(
            context,
            dx: 92,
            bottom: 76,
            tooltip: 'Search by title / author',
            onTap: onSearch,
            child: Icon(Icons.menu_book, color: onColor, size: 28),
          ),
        ],
      ),
    );
  }
}
