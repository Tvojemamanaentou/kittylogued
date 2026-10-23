import 'package:flutter/material.dart';

/// The main catalogue action. Its tooltip provides a full label on desktop hover.
class AddBookFab extends StatelessWidget {
  const AddBookFab({super.key, required this.isOpen, required this.onPressed});

  final bool isOpen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      key: const ValueKey('add-book-fab'),
      heroTag: 'add_book_fab',
      shape: const CircleBorder(),
      tooltip: isOpen ? 'Close add-book menu' : 'Add new book',
      onPressed: onPressed,
      child: AnimatedRotation(
        turns: isOpen ? 0.125 : 0,
        duration: const Duration(milliseconds: 200),
        child: const Icon(Icons.add, size: 44),
      ),
    );
  }
}

/// Actions displayed directly above the FAB. The parent places this widget and
/// [AddBookFab] in one docked column, so banners move the whole speed dial as a
/// single unit rather than pushing the trigger into independently positioned
/// bubbles.
class AddBookBubbles extends StatelessWidget {
  const AddBookBubbles({
    super.key,
    required this.isOpen,
    required this.onScan,
    required this.onIsbn,
    required this.onSearch,
    required this.batchMode,
    required this.onBatchChanged,
  });

  final bool isOpen;
  final VoidCallback onScan;
  final VoidCallback onIsbn;
  final VoidCallback onSearch;
  final bool batchMode;
  final ValueChanged<bool> onBatchChanged;

  Widget _action({
    required String keyName,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: FilledButton.tonalIcon(
        key: ValueKey(keyName),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: isOpen
          ? SizedBox(
              width: (MediaQuery.sizeOf(context).width - 24).clamp(0.0, 340.0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      elevation: 4,
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                      child: SwitchListTile(
                        key: const ValueKey('batch-mode-toggle'),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        secondary: const Icon(Icons.library_add_check_outlined),
                        title: const Text('Batch scan'),
                        subtitle: Text(
                          batchMode
                              ? 'Several books per session'
                              : 'One book at a time',
                        ),
                        value: batchMode,
                        onChanged: onBatchChanged,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _action(
                          keyName: 'scan-book-action',
                          label: 'Scan',
                          icon: Icons.qr_code_scanner,
                          onPressed: onScan,
                        ),
                        const SizedBox(width: 6),
                        _action(
                          keyName: 'isbn-book-action',
                          label: 'ISBN',
                          icon: Icons.numbers,
                          onPressed: onIsbn,
                        ),
                        const SizedBox(width: 6),
                        _action(
                          keyName: 'search-book-action',
                          label: 'Title / author',
                          icon: Icons.menu_book,
                          onPressed: onSearch,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('add-book-menu-closed')),
    );
  }
}
