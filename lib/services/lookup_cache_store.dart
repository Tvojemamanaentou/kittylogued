import 'dart:convert';

import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';

/// Remembers found books for 30 days. Failed lookups are not remembered,
/// because "not found" is often just "no internet".
class LookupCacheStore implements LookupCache {
  static const Duration maxAge = Duration(days: 30);

  final AppDatabase db;

  LookupCacheStore(this.db);

  @override
  Future<BookLookupResult?> get(String isbn) async {
    final row = await (db.select(db.lookupCacheEntries)
          ..where((t) => t.isbn.equals(isbn)))
        .getSingleOrNull();
    if (row == null) return null;
    if (DateTime.now().difference(row.fetchedAt) > maxAge) return null;
    final m = jsonDecode(row.payload) as Map<String, dynamic>;
    return BookLookupResult(
      title: m['title'] as String,
      author: m['author'] as String,
      isbn: m['isbn'] as String?,
      coverUrl: m['coverUrl'] as String?,
      publisher: m['publisher'] as String?,
      publicationYear: m['publicationYear'] as int?,
      pageCount: m['pageCount'] as int?,
      language: m['language'] as String?,
      secondaryContributors: m['secondaryContributors'] as String?,
      synopsis: m['synopsis'] as String?,
    );
  }

  @override
  Future<void> put(String isbn, BookLookupResult r) async {
    final payload = jsonEncode({
      'title': r.title,
      'author': r.author,
      'isbn': r.isbn,
      'coverUrl': r.coverUrl,
      'publisher': r.publisher,
      'publicationYear': r.publicationYear,
      'pageCount': r.pageCount,
      'language': r.language,
      'secondaryContributors': r.secondaryContributors,
      'synopsis': r.synopsis,
    });
    await db
        .into(db.lookupCacheEntries)
        .insertOnConflictUpdate(
          LookupCacheEntriesCompanion.insert(
            isbn: isbn,
            payload: payload,
            fetchedAt: DateTime.now(),
          ),
        );
  }
}
