import 'package:flutter/material.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/widgets/book_cover_thumbnail.dart';
import 'package:kittylogued/widgets/lending_dialogs.dart';

/// Everything that is currently lent out or borrowed, plus open requests.
class LendingPage extends StatelessWidget {
  const LendingPage({super.key});

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _section(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  Widget _tile(BuildContext context, AppServices s, LoanEntry entry) {
    final loan = entry.loan;
    final book = entry.book;
    final title = book?.title ?? loan.title ?? 'Untitled';
    final author = book?.author ?? loan.author;

    final String who;
    switch (loan.status) {
      case 'requested':
        who = 'Asked ${loan.personName} to lend it';
        break;
      case 'returned':
        who = loan.direction == 'lent'
            ? 'Was lent to ${loan.personName}'
            : 'Was borrowed from ${loan.personName}';
        break;
      default:
        who = loan.direction == 'lent'
            ? 'Lent to ${loan.personName}'
            : 'Borrowed from ${loan.personName}';
    }

    final today = DateTime.now();
    final overdue =
        loan.status == 'active' &&
        loan.dueAt != null &&
        loan.dueAt!.isBefore(DateTime(today.year, today.month, today.day));

    String? action;
    VoidCallback? onAction;
    switch (loan.status) {
      case 'requested':
        action = 'Cancel';
        onAction = () => s.repository.deleteLoan(loan.id);
        break;
      case 'active':
        action = loan.direction == 'lent' ? 'Got it back' : 'I returned it';
        onAction = () => s.repository.returnLoan(loan.id);
        break;
    }

    return ListTile(
      leading: book != null
          ? BookCoverThumbnail(
              isbn: book.isbn,
              coverUrl: book.coverUrl,
              cacheService: s.coverCache,
            )
          : const Icon(Icons.menu_book_outlined, size: 32),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      isThreeLine: true,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (author != null && author.isNotEmpty) Text(author),
          Text(who),
          if (loan.status == 'requested')
            const Text(
              'Saved - will be sent once friends are connected',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            )
          else if (loan.status == 'returned' && loan.returnedAt != null)
            Text(
              'Returned ${_fmt(loan.returnedAt!)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            )
          else
            Text(
              [
                'Since ${_fmt(loan.startedAt)}',
                if (loan.dueAt != null) 'due ${_fmt(loan.dueAt!)}',
                if (overdue) 'overdue',
              ].join(' • '),
              style: TextStyle(
                fontSize: 11,
                color: overdue ? Colors.redAccent : Colors.grey,
                fontWeight: overdue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
        ],
      ),
      trailing: action == null
          ? null
          : TextButton(onPressed: onAction, child: Text(action)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Lending / Borrowing'), centerTitle: true),
      body: StreamBuilder<List<LoanEntry>>(
        stream: s.database.watchLoanEntries(),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <LoanEntry>[];
          final requests = entries
              .where((e) => e.loan.status == 'requested')
              .toList();
          final lent = entries
              .where((e) => e.loan.status == 'active' && e.loan.direction == 'lent')
              .toList();
          final borrowed = entries
              .where(
                (e) => e.loan.status == 'active' && e.loan.direction == 'borrowed',
              )
              .toList();
          final returned = entries
              .where((e) => e.loan.status == 'returned')
              .take(30)
              .toList();

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: () => showAskToBorrowDialog(context),
                            icon: const Icon(Icons.person_search),
                            label: const Text('Ask a friend to lend me a book'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => showBorrowFromPersonDialog(context),
                            icon: const Icon(Icons.person_add_alt),
                            label: const Text('Borrow from someone without an account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Nothing lent or borrowed right now.\nUse the Lend button in the catalogue to lend a book.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  if (requests.isNotEmpty) ...[
                    _section(context, 'Requests', requests.length),
                    for (final e in requests) Card(child: _tile(context, s, e)),
                  ],
                  if (lent.isNotEmpty) ...[
                    _section(context, 'Lent out', lent.length),
                    for (final e in lent) Card(child: _tile(context, s, e)),
                  ],
                  if (borrowed.isNotEmpty) ...[
                    _section(context, 'Borrowed', borrowed.length),
                    for (final e in borrowed) Card(child: _tile(context, s, e)),
                  ],
                  if (returned.isNotEmpty)
                    ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        'Returned (${returned.length})',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      children: [
                        for (final e in returned) _tile(context, s, e),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
