import 'package:flutter/material.dart';
import 'database/app_database.dart';

late final AppDatabase database;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  database = AppDatabase();
  runApp(const KittyloguedApp());
}

class KittyloguedApp extends StatelessWidget {
  const KittyloguedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kittylogued',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const BookCatalogPage(),
    );
  }
}

class BookCatalogPage extends StatefulWidget {
  const BookCatalogPage({super.key});

  @override
  State createState() => _BookCatalogPageState();
}

class _BookCatalogPageState extends State {
  void _openAddBookDialog() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final isbnController = TextEditingController();
    final shelfController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Book to Catalog'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title *'),
              ),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Author *'),
              ),
              TextField(
                controller: isbnController,
                decoration: const InputDecoration(labelText: 'ISBN'),
              ),
              TextField(
                controller: shelfController,
                decoration: const InputDecoration(labelText: 'Shelf / Location'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final author = authorController.text.trim();

              if (title.isNotEmpty && author.isNotEmpty) {
                final isbn = isbnController.text.trim();
                final shelf = shelfController.text.trim();

                await database.insertBook(
                  title: title,
                  author: author,
                  isbn: isbn.isEmpty ? null : isbn,
                  shelfLocation: shelf.isEmpty ? null : shelf,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kittylogued Catalog'),
        centerTitle: false,
      ),
      body: StreamBuilder<List<Book>>(
        stream: database.watchAllBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(
              child: Text(
                'Your collection is empty.\nClick + to add your first book.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            itemCount: books.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final book = books[index];
              final shelf = book.shelfLocation;
              final subtitleText = (shelf != null && shelf.isNotEmpty)
                  ? book.author + ' | Shelf: ' + shelf
                  : book.author;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(book.title.isNotEmpty ? book.title[0].toUpperCase() : '?'),
                ),
                title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(subtitleText),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => database.deleteBook(book.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddBookDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),
    );
  }
}

