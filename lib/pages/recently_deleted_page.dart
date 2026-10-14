import 'package:flutter/material.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/repository/library_repository.dart';
import 'package:kittylogued/widgets/book_cover_thumbnail.dart';

/// The recycle bin: deleted books stay here for 30 days, then disappear.
class RecentlyDeletedPage extends StatelessWidget {
  const RecentlyDeletedPage({super.key});

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String message,
    String action,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);

    return StreamBuilder<List<Book>>(
      stream: services.database.watchDeletedBooks(),
      builder: (context, snapshot) {
        final books = snapshot.data ?? const <Book>[];
        return Scaffold(
          appBar: AppBar(
            title: const Text('Recently deleted'),
            actions: [
              TextButton(
                onPressed: books.isEmpty
                    ? null
                    : () async {
                        final ok = await _confirm(
                          context,
                          'Empty the bin?',
                          '${books.length} book(s) will be removed for good.',
                          'Empty bin',
                        );
                        if (ok) await services.repository.emptyBin();
                      },
                child: const Text('Empty bin'),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: books.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Nothing here.\nDeleted books stay for ${LibraryRepository.binKeepDays} days before they are removed for good.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: ListView.separated(
                      itemCount: books.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        final deleted = book.deletedAt ?? DateTime.now();
                        final left =
                            (LibraryRepository.binKeepDays -
                                    DateTime.now().difference(deleted).inDays)
                                .clamp(0, LibraryRepository.binKeepDays);
                        return ListTile(
                          leading: BookCoverThumbnail(
                            isbn: book.isbn,
                            coverUrl: book.coverUrl,
                            cacheService: services.coverCache,
                          ),
                          title: Text(book.title),
                          subtitle: Text(
                            '${book.author} • $left day(s) left',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.restore),
                                tooltip: 'Restore',
                                onPressed: () async {
                                  await services.repository.restore(book.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Restored "${book.title}"'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever_outlined),
                                tooltip: 'Delete forever',
                                onPressed: () async {
                                  final ok = await _confirm(
                                    context,
                                    'Delete forever?',
                                    '"${book.title}" will be removed for good.',
                                    'Delete',
                                  );
                                  if (ok) {
                                    await services.repository.deleteForever(
                                      book.id,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
        );
      },
    );
  }
}
