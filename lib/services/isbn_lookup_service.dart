import 'dart:convert';

import 'package:http/http.dart' as http;

/// Cleans author strings: strips lifespans (e.g., "1890-1938"), birth tags,
/// and converts "Čapek, Karel" to "Karel Čapek".
String cleanAuthorName(String raw) {
  if (raw.trim().isEmpty) return '';
  var s = raw.trim();

  s = s.replaceAll(
    RegExp(r',?\s*\(?(?:nar\.\s*)?\b\d{4}\s*[-–—]\s*\d{0,4}\)?$'),
    '',
  );
  s = s.replaceAll(RegExp(r',?\s*\(?(?:nar\.\s*)?\b\d{4}\)?$'), '');
  s = s.replaceAll(RegExp(r',?\s*nar\.\s*\d{4}$'), '');
  s = s.trim();

  if (s.contains(',') && !s.contains(';') && s.split(',').length == 2) {
    final parts = s.split(',');
    final surname = parts[0].trim();
    final forename = parts[1].trim();
    if (surname.isNotEmpty && forename.isNotEmpty) {
      s = '$forename $surname';
    }
  }

  s = s.replaceAll(RegExp(r'[,.\s]+$'), '').trim();
  return s;
}

/// Helper extracting clean 10- or 13-character ISBNs from Strings or Lists.
String? extractIsbn(dynamic val) {
  if (val == null) return null;
  if (val is String) {
    final clean = val.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
    if (clean.length == 10 || clean.length == 13) return clean;
    return null;
  }
  if (val is List) {
    // Prefer 13-digit EAN-13 first
    for (final item in val) {
      final clean = item
          .toString()
          .replaceAll(RegExp(r'[^0-9Xx]'), '')
          .toUpperCase();
      if (clean.length == 13) return clean;
    }
    // Fallback to 10-digit
    for (final item in val) {
      final clean = item
          .toString()
          .replaceAll(RegExp(r'[^0-9Xx]'), '')
          .toUpperCase();
      if (clean.length == 10) return clean;
    }
  }
  return null;
}

/// Helper extracting a 4-digit year from Strings, ints, or date Lists.
int? extractYear(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is List && val.isNotEmpty) {
    for (final item in val) {
      final y = extractYear(item);
      if (y != null) return y;
    }
    return null;
  }
  final str = val.toString();
  final match = RegExp(r'\b(1[89]\d{2}|20\d{2})\b').firstMatch(str);
  return match != null ? int.tryParse(match.group(0)!) : null;
}

/// Helper extracting and cleaning publisher strings from MARC/API formats.
String? extractPublisher(dynamic val) {
  if (val == null) return null;
  String? raw;
  if (val is String && val.trim().isNotEmpty) {
    raw = val.trim();
  } else if (val is List && val.isNotEmpty) {
    raw = val.first?.toString().trim();
  }
  if (raw == null || raw.isEmpty) return null;

  raw = raw.replaceFirst(
    RegExp(r'^[^:]+:\s*'),
    '',
  ); // Strip place of publication
  raw = raw.replaceFirst(RegExp(r',?\s*\d{4}.*$'), ''); // Strip trailing year
  raw = raw.replaceAll(RegExp(r'[\[\]]'), '').trim();
  raw = raw.replaceAll(RegExp(r'[,.\s]+$'), '').trim();
  return raw.isNotEmpty ? raw : null;
}

/// Immutable data container holding rich metadata fetched from an online query.
/// Where finished lookups are remembered between runs.
abstract class LookupCache {
  Future<BookLookupResult?> get(String isbn);
  Future<void> put(String isbn, BookLookupResult result);
}

class BookLookupResult {
  final String title;
  final String author;
  final String? isbn;
  final String? coverUrl;
  final String? publisher;
  final int? publicationYear;
  final int? pageCount;
  final String? language;
  final String? secondaryContributors;
  final String? synopsis;

  const BookLookupResult({
    required this.title,
    required this.author,
    this.isbn,
    this.coverUrl,
    this.publisher,
    this.publicationYear,
    this.pageCount,
    this.language,
    this.secondaryContributors,
    this.synopsis,
  });

  BookLookupResult copyWith({
    String? title,
    String? author,
    String? isbn,
    String? coverUrl,
    String? publisher,
    int? publicationYear,
    int? pageCount,
    String? language,
    String? secondaryContributors,
    String? synopsis,
  }) {
    return BookLookupResult(
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      coverUrl: coverUrl ?? this.coverUrl,
      publisher: publisher ?? this.publisher,
      publicationYear: publicationYear ?? this.publicationYear,
      pageCount: pageCount ?? this.pageCount,
      language: language ?? this.language,
      secondaryContributors:
          secondaryContributors ?? this.secondaryContributors,
      synopsis: synopsis ?? this.synopsis,
    );
  }
}

/// Service querying book metadata across Knihovny.cz, Google Books, and Open Library.
class IsbnLookupService {
  /// Optional store for lookup results (set once at startup).
  static LookupCache? cache;

  final http.Client _client;
  final String? googleBooksApiKey;

  IsbnLookupService({http.Client? client, this.googleBooksApiKey})
    : _client = client ?? http.Client();

  /// Looks a book up by ISBN. If the catalogue that answered had no page
  /// count, other sources are asked for it.
  Future<BookLookupResult?> lookupByIsbn(
    String rawIsbn, {
    bool useCache = true,
  }) async {
    final key = rawIsbn.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
    if (useCache && key.isNotEmpty) {
      try {
        final hit = await cache?.get(key);
        if (hit != null) return hit;
      } catch (_) {}
    }
    final result = await _lookupByIsbnBasic(rawIsbn);
    if (result == null) return null;
    final enriched = await withPageCount(result);
    if (key.isNotEmpty) {
      try {
        await cache?.put(key, enriched);
      } catch (_) {}
    }
    return enriched;
  }

  /// Returns [result] with a page count filled in when it was missing.
  Future<BookLookupResult> withPageCount(BookLookupResult result) async {
    if (result.pageCount != null && result.pageCount! > 0) return result;
    final isbn = result.isbn;
    if (isbn == null || isbn.isEmpty) return result;
    final pages = await lookupPageCount(isbn);
    return pages == null ? result : result.copyWith(pageCount: pages);
  }

  /// Tries several authorities in turn and returns the first page count found:
  /// 1. knihovny.cz (central portal of Czech libraries; includes the union
  ///    catalogue records), looking at every record for the ISBN
  /// 2. Open Library
  /// 3. Google Books
  /// To add another source, write a `Future<int?> _pageCountFromX(String isbn)`
  /// method and add it to the list below.
  Future<int?> lookupPageCount(String rawIsbn) async {
    final isbn = rawIsbn.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
    if (isbn.length != 10 && isbn.length != 13) return null;

    final sources = <Future<int?> Function(String)>[
      _pageCountFromKnihovny,
      _pageCountFromOpenLibrary,
      _pageCountFromGoogleBooks,
    ];
    for (final source in sources) {
      try {
        final pages = await source(isbn);
        if (pages != null && pages >= 8 && pages <= 10000) return pages;
      } catch (_) {
        // Try the next source.
      }
    }
    return null;
  }

  Future<dynamic> _getJson(Uri uri) async {
    final response = await _client
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'KittyloguedApp/1.0',
          },
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    return jsonDecode(response.body);
  }

  Future<int?> _pageCountFromKnihovny(String isbn) async {
    final data = await _getJson(
      Uri.parse(
        'https://www.knihovny.cz/api/v1/search?lookfor=$isbn&type=AllFields&limit=10',
      ),
    );
    if (data is! Map) return null;
    final records = data['records'];
    if (records is! List) return null;

    final pageRegex = RegExp(
      r'(\d{1,5})\s*(?:s\.|stran|str\.|pages|p\.)',
      caseSensitive: false,
    );
    for (final record in records) {
      if (record is! Map) continue;
      final descs = record['physicalDescriptions'];
      if (descs is! List) continue;
      for (final d in descs) {
        final match = pageRegex.firstMatch(d.toString());
        final pages = match == null ? null : int.tryParse(match.group(1)!);
        if (pages != null && pages >= 8) return pages;
      }
    }
    return null;
  }

  Future<int?> _pageCountFromOpenLibrary(String isbn) async {
    final data = await _getJson(
      Uri.parse(
        'https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&format=json&jscmd=data',
      ),
    );
    if (data is! Map) return null;
    final entry = data['ISBN:$isbn'];
    if (entry is! Map) return null;
    final pages = entry['number_of_pages'];
    return pages is int ? pages : int.tryParse('$pages');
  }

  Future<int?> _pageCountFromGoogleBooks(String isbn) async {
    final data = await _getJson(
      Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'),
    );
    if (data is! Map) return null;
    final items = data['items'];
    if (items is! List) return null;
    for (final item in items) {
      if (item is! Map) continue;
      final info = item['volumeInfo'];
      if (info is! Map) continue;
      final pages = info['pageCount'];
      if (pages is int && pages > 0) return pages;
    }
    return null;
  }

  /// Queries metadata by ISBN with automated provider fallback.
  Future<BookLookupResult?> _lookupByIsbnBasic(String rawIsbn) async {
    final cleanIsbn = rawIsbn.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
    if (cleanIsbn.length != 10 && cleanIsbn.length != 13) return null;
    if (RegExp(r'^0+$').hasMatch(cleanIsbn)) return null;

    // 1. Try Knihovny.cz first
    final knihovnyResult = await _lookupKnihovnyCz(cleanIsbn);
    if (knihovnyResult != null) return knihovnyResult;

    // 2. Try Google Books (no API key required)
    final googleResult = await _lookupGoogleBooks(cleanIsbn);
    if (googleResult != null) return googleResult;

    // 3. Fallback to Open Library
    final openLibraryResult = await _lookupOpenLibrary(cleanIsbn);
    if (openLibraryResult != null) {
      if (openLibraryResult.coverUrl == null) {
        final fallbackCover =
            'https://www.knihovny.cz/Cover/Show?isbn=$cleanIsbn&size=medium';
        return openLibraryResult.copyWith(coverUrl: fallbackCover);
      }
      return openLibraryResult;
    }

    return null;
  }

  /// Searches candidate books by title, author, or keyword query across multiple catalogs.
  Future<List<BookLookupResult>> searchBooks({
    String? title,
    String? author,
    String? query,
  }) async {
    final List<BookLookupResult> results = [];
    final terms = [title, author, query]
        .where((t) => t != null && t.trim().isNotEmpty)
        .map((t) => t!.trim())
        .toList();

    if (terms.isEmpty) return results;
    final combinedQuery = terms.join(' ');

    // 1. Search Google Books (returns reliable ISBN-13, publisher, and year)
    final googleResults = await _searchGoogleBooks(combinedQuery);
    results.addAll(googleResults);

    // 2. Search Knihovny.cz (Czech National Union Catalogue)
    final czechResults = await _searchKnihovnyCz(combinedQuery);
    for (final item in czechResults) {
      final exists = results.any(
        (r) =>
            r.title.toLowerCase() == item.title.toLowerCase() &&
            (r.isbn == item.isbn ||
                r.author.toLowerCase() == item.author.toLowerCase()),
      );
      if (!exists) {
        results.add(item);
      }
    }

    // 3. Search Open Library
    final olResults = await _searchOpenLibrary(combinedQuery);
    for (final item in olResults) {
      final exists = results.any(
        (r) =>
            r.title.toLowerCase() == item.title.toLowerCase() &&
            (r.isbn == item.isbn ||
                r.author.toLowerCase() == item.author.toLowerCase()),
      );
      if (!exists) {
        results.add(item);
      }
    }

    return results;
  }

  Future<BookLookupResult?> _lookupKnihovnyCz(String cleanIsbn) async {
    final uri = Uri.parse(
      'https://www.knihovny.cz/api/v1/search?lookfor=$cleanIsbn',
    );
    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'KittyloguedApp/1.0',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;
      final Map data = jsonDecode(response.body) as Map;
      final records = data['records'] as List?;
      if (records == null || records.isEmpty) return null;

      return _parseKnihovnyRecord(
        records.first as Map,
        fallbackIsbn: cleanIsbn,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<BookLookupResult>> _searchKnihovnyCz(String query) async {
    final uri = Uri.parse(
      'https://www.knihovny.cz/api/v1/search?lookfor=${Uri.encodeComponent(query)}&type=AllFields&limit=10',
    );
    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'KittyloguedApp/1.0',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return [];
      final Map data = jsonDecode(response.body) as Map;
      final records = data['records'] as List?;
      if (records == null || records.isEmpty) return [];

      return records.map((r) => _parseKnihovnyRecord(r as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  BookLookupResult _parseKnihovnyRecord(Map r, {String? fallbackIsbn}) {
    String title = r['title'] as String? ?? 'Unknown Title';
    if (title.contains(' / ')) {
      title = title.split(' / ').first.trim();
    }

    final List<String> primaryAuthors = [];
    final List<String> secondaryList = [];

    if (r.containsKey('authors') && r['authors'] is Map) {
      final authorsMap = r['authors'] as Map;

      if (authorsMap['primary'] is Map) {
        final primary = authorsMap['primary'] as Map;
        for (final k in primary.keys) {
          final clean = cleanAuthorName(k.toString());
          if (clean.isNotEmpty) primaryAuthors.add(clean);
        }
      }

      if (authorsMap['secondary'] is Map) {
        final secondary = authorsMap['secondary'] as Map;
        for (final entry in secondary.entries) {
          final clean = cleanAuthorName(entry.key.toString());
          String role = '';
          if (entry.value is List && (entry.value as List).isNotEmpty) {
            role = ' (${(entry.value as List).first})';
          }
          if (clean.isNotEmpty) secondaryList.add('$clean$role');
        }
      }
    }

    final author = primaryAuthors.isNotEmpty
        ? primaryAuthors.join(', ')
        : 'Unknown Author';
    final secondaryContributors = secondaryList.isNotEmpty
        ? secondaryList.join(', ')
        : null;

    final publisher = extractPublisher(r['publishers'] ?? r['publisher']);

    int? year = extractYear(r['year']);
    year ??= extractYear(r['publicationDates']);
    year ??= extractYear(r['publishDate']);

    int? pageCount;
    if (r.containsKey('physicalDescriptions') &&
        r['physicalDescriptions'] is List) {
      final descs = r['physicalDescriptions'] as List;
      if (descs.isNotEmpty) {
        final descStr = descs.first.toString();
        final pageMatch = RegExp(
          r'(\d+)\s*(?:s\.|stran|str\.|pages|p\.)',
          caseSensitive: false,
        ).firstMatch(descStr);
        if (pageMatch != null) {
          pageCount = int.tryParse(pageMatch.group(1)!);
        }
      }
    }

    String? resolvedIsbn = fallbackIsbn;
    resolvedIsbn ??= extractIsbn(r['cleanIsbn']);
    resolvedIsbn ??= extractIsbn(r['isbns']);
    resolvedIsbn ??= extractIsbn(r['isbn']);

    String? coverUrl;
    if (resolvedIsbn != null && resolvedIsbn.isNotEmpty) {
      coverUrl =
          'https://www.knihovny.cz/Cover/Show?isbn=$resolvedIsbn&size=medium';
    }

    String? synopsis;
    if (r.containsKey('summary')) {
      if (r['summary'] is List && (r['summary'] as List).isNotEmpty) {
        synopsis = (r['summary'] as List).first.toString().trim();
      } else if (r['summary'] is String) {
        synopsis = (r['summary'] as String).trim();
      }
    }

    return BookLookupResult(
      title: title,
      author: author,
      isbn: resolvedIsbn,
      coverUrl: coverUrl,
      publisher: publisher,
      publicationYear: year,
      pageCount: pageCount,
      language: 'cze',
      secondaryContributors: secondaryContributors,
      synopsis: synopsis,
    );
  }

  Future<List<BookLookupResult>> _searchGoogleBooks(String query) async {
    final keyParam =
        (googleBooksApiKey != null && googleBooksApiKey!.isNotEmpty)
        ? '&key=$googleBooksApiKey'
        : '';
    final uri = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}&maxResults=8$keyParam',
    );

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return [];
      final Map data = jsonDecode(response.body) as Map;
      final items = data['items'] as List?;
      if (items == null || items.isEmpty) return [];

      return items
          .map((item) => _parseGoogleBooksItem(item as Map))
          .whereType<BookLookupResult>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<BookLookupResult?> _lookupGoogleBooks(String cleanIsbn) async {
    final keyParam =
        (googleBooksApiKey != null && googleBooksApiKey!.isNotEmpty)
        ? '&key=$googleBooksApiKey'
        : '';
    final uri = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=isbn:$cleanIsbn$keyParam',
    );

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;
      final Map data = jsonDecode(response.body) as Map;
      final items = data['items'] as List?;
      if (items == null || items.isEmpty) return null;

      return _parseGoogleBooksItem(items.first as Map, fallbackIsbn: cleanIsbn);
    } catch (_) {
      return null;
    }
  }

  BookLookupResult? _parseGoogleBooksItem(Map item, {String? fallbackIsbn}) {
    final volumeInfo = item['volumeInfo'] as Map?;
    if (volumeInfo == null) return null;

    final title = volumeInfo['title'] as String? ?? 'Unknown Title';
    String author = 'Unknown Author';
    if (volumeInfo.containsKey('authors') && volumeInfo['authors'] is List) {
      final authorsList = (volumeInfo['authors'] as List)
          .map((a) => cleanAuthorName(a.toString()))
          .where((a) => a.isNotEmpty)
          .toList();
      if (authorsList.isNotEmpty) author = authorsList.join(', ');
    }

    String? isbn = fallbackIsbn;
    if (volumeInfo.containsKey('industryIdentifiers') &&
        volumeInfo['industryIdentifiers'] is List) {
      final ids = volumeInfo['industryIdentifiers'] as List;
      for (final id in ids) {
        if (id is Map && id['type'] == 'ISBN_13') {
          isbn = extractIsbn(id['identifier']);
          break;
        }
      }
      if (isbn == null) {
        for (final id in ids) {
          if (id is Map && id['type'] == 'ISBN_10') {
            isbn = extractIsbn(id['identifier']);
            break;
          }
        }
      }
    }

    final publisher = extractPublisher(volumeInfo['publisher']);
    final year = extractYear(volumeInfo['publishedDate']);
    final pageCount = volumeInfo['pageCount'] as int?;

    String? coverUrl;
    if (volumeInfo.containsKey('imageLinks') &&
        volumeInfo['imageLinks'] is Map) {
      final images = volumeInfo['imageLinks'] as Map;
      coverUrl =
          images['thumbnail'] as String? ?? images['smallThumbnail'] as String?;
      if (coverUrl != null && coverUrl.startsWith('http://')) {
        coverUrl = coverUrl.replaceFirst('http://', 'https://');
      }
    }

    return BookLookupResult(
      title: title,
      author: author,
      isbn: isbn,
      coverUrl: coverUrl,
      publisher: publisher,
      publicationYear: year,
      pageCount: pageCount,
      language: volumeInfo['language'] as String? ?? 'cze',
      synopsis: volumeInfo['description'] as String?,
    );
  }

  Future<BookLookupResult?> _lookupOpenLibrary(String cleanIsbn) async {
    final uri = Uri.parse(
      'https://openlibrary.org/search.json?isbn=$cleanIsbn',
    );
    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'KittyloguedApp/1.0',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;
      final Map data = jsonDecode(response.body) as Map;
      final docs = data['docs'] as List?;
      if (docs == null || docs.isEmpty) return null;

      return _parseOpenLibraryDoc(docs.first as Map, cleanIsbn);
    } catch (_) {
      return null;
    }
  }

  Future<List<BookLookupResult>> _searchOpenLibrary(String query) async {
    final uri = Uri.parse(
      'https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&limit=8',
    );
    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'KittyloguedApp/1.0',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return [];
      final Map data = jsonDecode(response.body) as Map;
      final docs = data['docs'] as List?;
      if (docs == null || docs.isEmpty) return [];

      return docs.map((d) => _parseOpenLibraryDoc(d as Map, null)).toList();
    } catch (_) {
      return [];
    }
  }

  BookLookupResult _parseOpenLibraryDoc(Map doc, String? fallbackIsbn) {
    final title = doc['title'] as String? ?? 'Unknown Title';

    String author = 'Unknown Author';
    if (doc.containsKey('author_name') && doc['author_name'] is List) {
      final authorsList = (doc['author_name'] as List)
          .map((item) => cleanAuthorName(item.toString()))
          .where((item) => item.isNotEmpty)
          .toList();
      if (authorsList.isNotEmpty) author = authorsList.join(', ');
    }

    final publisher = extractPublisher(doc['publisher']);

    int? year = extractYear(doc['first_publish_year']);
    year ??= extractYear(doc['publish_year']);
    year ??= extractYear(doc['publish_date']);

    int? pageCount = doc['number_of_pages_median'] as int?;

    String? resolvedIsbn = fallbackIsbn;
    resolvedIsbn ??= extractIsbn(doc['isbn']);

    String? coverUrl;
    if (doc.containsKey('cover_i') && doc['cover_i'] != null) {
      final coverId = doc['cover_i'].toString();
      coverUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    } else if (resolvedIsbn != null && resolvedIsbn.isNotEmpty) {
      coverUrl =
          'https://www.knihovny.cz/Cover/Show?isbn=$resolvedIsbn&size=medium';
    }

    return BookLookupResult(
      title: title,
      author: author,
      isbn: resolvedIsbn,
      coverUrl: coverUrl,
      publisher: publisher,
      publicationYear: year,
      pageCount: pageCount,
      language: 'cze',
    );
  }
}
