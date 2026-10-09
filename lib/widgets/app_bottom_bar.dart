import 'package:flutter/material.dart';

/// Bottom navigation bar with a notch in the middle for the Add button.
///
/// Slots: 0 = Home, 1 = Lending/Borrowing, (centre notch), 2 = Catalogue,
/// 3 = Personal account.
class AppBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AppBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  Widget _item(BuildContext context, int index, IconData icon, String tip) {
    final selected = selectedIndex == index;
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: IconButton(
        tooltip: tip,
        onPressed: () => onSelected(index),
        icon: Icon(icon, size: 28),
        color: selected ? scheme.primary : scheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      height: 64,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          _item(context, 0, Icons.home_outlined, 'Home'),
          _item(context, 1, Icons.swap_horiz, 'Lending / Borrowing'),
          const SizedBox(width: 112), // room for the notch + big plus button
          _item(context, 2, Icons.menu_book_outlined, 'Catalogue'),
          _item(context, 3, Icons.person_outline, 'Personal account'),
        ],
      ),
    );
  }
}
