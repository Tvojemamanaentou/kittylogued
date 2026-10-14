import 'package:flutter/material.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/pages/book_form_page.dart';
import 'package:kittylogued/widgets/book_detail_pane.dart';
import 'package:kittylogued/widgets/lending_dialogs.dart';
import 'package:kittylogued/widgets/quick_update_sheet.dart';

/// Full-screen details of one book (used on phones; wide windows show the
/// same content in a side panel). Has an Edit button.
class BookDetailPage extends StatelessWidget {
  final int bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);

    return StreamBuilder<Book?>(
      stream: s.database.watchBook(bookId),
      builder: (context, bookSnapshot) {
        final book = bookSnapshot.data;
        if (book == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: bookSnapshot.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator()
                  : const Text(
                      'This book is no longer available.',
                      style: TextStyle(color: Colors.grey),
                    ),
            ),
          );
        }

        return StreamBuilder<Map<int, List<Tag>>>(
          stream: s.database.watchTagsByBook(),
          builder: (context, tagSnapshot) {
            return StreamBuilder<List<LoanEntry>>(
              stream: s.database.watchLoanEntries(),
              builder: (context, loanSnapshot) {
                Loan? loan;
                for (final e in loanSnapshot.data ?? const <LoanEntry>[]) {
                  if (e.loan.bookId == book.id &&
                      e.loan.direction == 'lent' &&
                      e.loan.status == 'active') {
                    loan = e.loan;
                    break;
                  }
                }

                void edit() => openBookForm(
                  context,
                  database: s.database,
                  repository: s.repository,
                  coverCacheService: s.coverCache,
                  book: book,
                );

                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    actions: [
                      TextButton.icon(
                        onPressed: edit,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                  body: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: BookDetailPane(
                        book: book,
                        tags: tagSnapshot.data?[book.id] ?? const <Tag>[],
                        coverCache: s.coverCache,
                        loan: loan,
                        onEdit: edit,
                        onQuickUpdate: () => showQuickUpdateSheet(
                          context,
                          book: book,
                          repository: s.repository,
                        ),
                        onLendOrReturn: () =>
                            lendOrReturnBook(context, book, loan),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
