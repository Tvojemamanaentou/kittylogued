import 'dart:convert';

import 'package:http/http.dart' as http;

/// Immutable data container holding metadata fetched from an ISBN query.
class BookLookupResult {
  final String title;
  final String author;
  final String? coverUrl;

  const BookLookupResult({
    required this.title,
    required this.author,
    this.coverUrl,
  });

  BookLookupResult copyWith({String? title, String? author, String? coverUrl}) {
    return BookLookupResult(
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}

/// Service responsible for querying book metadata across multiple public providers.
class IsbnLookupService {
  final http.Client _client;
  final String? googleBooksApiKey;

  IsbnLookupService({http.Client? client, this.googleBooksApiKey})
    : _client = client ?? http.Client();

  /// Queries book metadata matching [rawIsbn].
  ///
  /// Tries Open Library first. If not found, tries Knihovny.cz.
  /// If an optional Google Books API key was provided, falls back to Google Books.
  Future lookupByIsbn(String rawIsbn) async {
    final cleanIsbn = rawIsbn.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();

    if (cleanIsbn.length != 10 && cleanIsbn.length != 13) {
      return null;
    }

    if (RegExp(r'^0+$').hasMatch(cleanIsbn)) {
      return null;
    }

    // 1. Try Open Library
    final openLibraryResult = await _lookupOpenLibrary(cleanIsbn);
    if (openLibraryResult != null) {
      // If Open Library provided metadata but no cover artwork, try the Knihovny.cz cover router
      if (openLibraryResult.coverUrl == null) {
        final fallbackCover =
            'https://www.knihovny.cz/Cover/Show?isbn=' +
            cleanIsbn +
            '&size=medium';
        return openLibraryResult.copyWith(coverUrl: fallbackCover);
      }
      return openLibraryResult;
    }

    // 2. Try Knihovny.cz (Central Czech Library Portal)
    final knihovnyResult = await _lookupKnihovnyCz(cleanIsbn);
    if (knihovnyResult != null) {
      return knihovnyResult;
    }

    // 3. Fallback to Google Books only if an API key is available
    final apiKey = googleBooksApiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      return await _lookupGoogleBooks(cleanIsbn, apiKey);
    }

    return null;
  }

  Future _lookupOpenLibrary(String cleanIsbn) async {
    final uri = Uri.parse(
      'https://openlibrary.org/search.json?isbn=' + cleanIsbn,
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'KittyloguedApp/1.0 (https://github.com/Tvojemamanaentou/kittylogued)',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return null;
      }

      final Map data = jsonDecode(response.body) as Map;

      final docs = data['docs'] as List?;
      if (docs == null || docs.isEmpty) {
        return null;
      }

      final firstDoc = docs.first as Map;
      final title = firstDoc['title'] as String? ?? 'Unknown Title';

      String author = 'Unknown Author';
      if (firstDoc.containsKey('author_name') &&
          firstDoc['author_name'] is List) {
        final authorsList = firstDoc['author_name'] as List;
        final names = authorsList
            .where((item) => item != null && item.toString().trim().isNotEmpty)
            .map((item) => item.toString().trim())
            .toList();

        if (names.isNotEmpty) {
          author = names.join(', ');
        }
      }

      String? coverUrl;
      if (firstDoc.containsKey('cover_i') && firstDoc['cover_i'] != null) {
        final coverId = firstDoc['cover_i'].toString();
        coverUrl = 'https://covers.openlibrary.org/b/id/' + coverId + '-M.jpg';
      }

      return BookLookupResult(title: title, author: author, coverUrl: coverUrl);
    } catch (_) {
      return null;
    }
  }

  Future _lookupKnihovnyCz(String cleanIsbn) async {
    final uri = Uri.parse(
      'https://www.knihovny.cz/api/v1/search?lookfor=' + cleanIsbn,
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'KittyloguedApp/1.0 (https://github.com/Tvojemamanaentou/kittylogued)',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return null;
      }

      final Map data = jsonDecode(response.body) as Map;

      final records = data['records'] as List?;
      if (records == null || records.isEmpty) {
        return null;
      }

      final firstRecord = records.first as Map;

      // 1. Extract Title
      String title = firstRecord['title'] as String? ?? 'Unknown Title';
      if (title.contains(' / ')) {
        title = title.split(' / ').first.trim();
      }

      // 2. Extract Author(s)
      String author = 'Unknown Author';
      if (firstRecord.containsKey('authors') && firstRecord['authors'] is Map) {
        final authorsMap = firstRecord['authors'] as Map;
        final names = [];

        if (authorsMap.containsKey('primary') && authorsMap['primary'] is Map) {
          final primaryMap = authorsMap['primary'] as Map;
          names.addAll(
            primaryMap.keys.map((k) => k.trim()).where((k) => k.isNotEmpty),
          );
        }

        if (names.isEmpty &&
            authorsMap.containsKey('secondary') &&
            authorsMap['secondary'] is Map) {
          final secondaryMap = authorsMap['secondary'] as Map;
          names.addAll(
            secondaryMap.keys.map((k) => k.trim()).where((k) => k.isNotEmpty),
          );
        }

        if (names.isNotEmpty) {
          author = names.join(', ');
        }
      }

      // 3. Cover URL routed via Knihovny.cz VuFind proxy
      final coverUrl =
          'https://www.knihovny.cz/Cover/Show?isbn=' +
          cleanIsbn +
          '&size=medium';

      return BookLookupResult(title: title, author: author, coverUrl: coverUrl);
    } catch (_) {
      return null;
    }
  }

  Future _lookupGoogleBooks(String cleanIsbn, String apiKey) async {
    final uri = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=isbn:' +
          cleanIsbn +
          '&key=' +
          apiKey,
    );

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return null;
      }

      final Map data = jsonDecode(response.body) as Map;

      final totalItems = data['totalItems'] as int? ?? 0;
      if (totalItems == 0 || !data.containsKey('items')) {
        return null;
      }

      final items = data['items'] as List?;
      if (items == null || items.isEmpty) {
        return null;
      }

      final firstItem = items.first as Map;
      final volumeInfo = firstItem['volumeInfo'] as Map?;
      if (volumeInfo == null) {
        return null;
      }

      final title = volumeInfo['title'] as String? ?? 'Unknown Title';

      String author = 'Unknown Author';
      if (volumeInfo.containsKey('authors') && volumeInfo['authors'] is List) {
        final authorsList = volumeInfo['authors'] as List;
        final names = authorsList
            .where((item) => item != null && item.toString().trim().isNotEmpty)
            .map((item) => item.toString().trim())
            .toList();

        if (names.isNotEmpty) {
          author = names.join(', ');
        }
      }

      String? coverUrl;
      if (volumeInfo.containsKey('imageLinks') &&
          volumeInfo['imageLinks'] is Map) {
        final images = volumeInfo['imageLinks'] as Map;
        coverUrl =
            images['thumbnail'] as String? ??
            images['smallThumbnail'] as String?;
        if (coverUrl != null && coverUrl.startsWith('http://')) {
          coverUrl = coverUrl.replaceFirst('http://', 'https://');
        }
      }

      return BookLookupResult(title: title, author: author, coverUrl: coverUrl);
    } catch (_) {
      return null;
    }
  }
}
