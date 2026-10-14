import 'package:flutter/material.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/widgets/person_picker.dart';

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

double _dialogContentWidth(BuildContext context) =>
    (MediaQuery.sizeOf(context).width - 128).clamp(0.0, 420.0).toDouble();

Future<DateTime?> _pickDueDate(BuildContext context, DateTime? current) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: current ?? now.add(const Duration(days: 14)),
    firstDate: DateTime(now.year - 1),
    lastDate: DateTime(now.year + 5),
  );
}

Widget _dueDateButton(
  BuildContext context,
  DateTime? due,
  ValueChanged<DateTime?> onChanged,
) {
  return Wrap(
    spacing: 4,
    runSpacing: 4,
    children: [
      OutlinedButton.icon(
        icon: const Icon(Icons.event, size: 18),
        label: Text(
          due == null ? 'Due date (optional)' : 'Due ${_fmtDate(due)}',
        ),
        onPressed: () async {
          final picked = await _pickDueDate(context, due);
          if (picked != null) onChanged(picked);
        },
      ),
      if (due != null)
        IconButton(
          icon: const Icon(Icons.clear, size: 18),
          tooltip: 'Clear due date',
          onPressed: () => onChanged(null),
        ),
    ],
  );
}

/// Lends the book, or (when it is already lent out) marks it as returned.
Future<void> lendOrReturnBook(
  BuildContext context,
  Book book,
  Loan? loan,
) async {
  if (loan == null) {
    await showLendBookDialog(context, book);
    return;
  }
  final services = AppScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Mark as returned?'),
      content: Text(
        '"${book.title}" was lent to ${loan.personName}. Is it back on your shelf?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Not yet'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Returned'),
        ),
      ],
    ),
  );
  if (ok == true) {
    await services.repository.returnLoan(loan.id);
    messenger.showSnackBar(
      SnackBar(content: Text('"${book.title}" is back on your shelf')),
    );
  }
}

/// Centered dialog: pick a friend or type a nickname, optional due date.
Future<void> showLendBookDialog(BuildContext context, Book book) async {
  final services = AppScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  PersonChoice? person;
  DateTime? due;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setLocal) => AlertDialog(
        scrollable: true,
        title: Text(
          'Lend "${book.title}"',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SizedBox(
          width: _dialogContentWidth(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PersonPicker(onChanged: (p) => setLocal(() => person = p)),
              const SizedBox(height: 12),
              _dueDateButton(context, due, (d) => setLocal(() => due = d)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: person == null
                ? null
                : () => Navigator.of(dialogContext).pop(true),
            child: const Text('Lend'),
          ),
        ],
      ),
    ),
  );

  final chosen = person;
  if (confirmed == true && chosen != null) {
    await services.repository.lendBook(
      book,
      personName: chosen.name,
      personUserId: chosen.userId,
      dueAt: due,
    );
    messenger.showSnackBar(
      SnackBar(content: Text('Lent "${book.title}" to ${chosen.name}')),
    );
  }
}

/// Ask a friend to lend me a book (saved now, sent to the friend later).
Future<void> showAskToBorrowDialog(BuildContext context) async {
  final services = AppScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final title = TextEditingController();
  final author = TextEditingController();
  PersonChoice? friend;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setLocal) => AlertDialog(
        scrollable: true,
        title: const Text('Ask a friend to lend a book'),
        content: SizedBox(
          width: _dialogContentWidth(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PersonPicker(
                allowNickname: false,
                onChanged: (p) => setLocal(() => friend = p),
              ),
              const SizedBox(height: 12),
              // TODO: pick the book from the friend's catalogue once it exists.
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Book title *',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setLocal(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: author,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: friend == null || title.text.trim().isEmpty
                ? null
                : () => Navigator.of(dialogContext).pop(true),
            child: const Text('Send request'),
          ),
        ],
      ),
    ),
  );

  final chosen = friend;
  if (confirmed == true && chosen != null) {
    await services.repository.requestBorrow(
      friendName: chosen.name,
      friendUserId: chosen.userId,
      title: title.text,
      author: author.text.trim().isEmpty ? null : author.text,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Request to ${chosen.name} saved. It will be sent once friends are connected.',
        ),
      ),
    );
  }
}

/// Record a book borrowed from someone without an account.
Future<void> showBorrowFromPersonDialog(BuildContext context) async {
  final services = AppScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final person = TextEditingController();
  final title = TextEditingController();
  final author = TextEditingController();
  DateTime? due;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setLocal) => AlertDialog(
        scrollable: true,
        title: const Text('Borrow from someone without an account'),
        content: SizedBox(
          width: _dialogContentWidth(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: person,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Who lent it to you? *',
                  hintText: 'Name or nickname',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setLocal(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Book title *',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setLocal(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: author,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _dueDateButton(context, due, (d) => setLocal(() => due = d)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: person.text.trim().isEmpty || title.text.trim().isEmpty
                ? null
                : () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );

  if (confirmed == true) {
    await services.repository.borrowFromPerson(
      personName: person.text,
      title: title.text,
      author: author.text.trim().isEmpty ? null : author.text,
      dueAt: due,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Saved: "${title.text.trim()}" from ${person.text.trim()}',
        ),
      ),
    );
  }
}
