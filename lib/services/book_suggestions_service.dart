import 'dart:convert';

import 'package:http/http.dart' as http;

class SuggestedBook {
  final String title;
  final String author;
  final String? isbn;
  final String? coverUrl;
  final String? blurb;

  const SuggestedBook({
    required this.title,
    required this.author,
    this.isbn,
    this.coverUrl,
    this.blurb,
  });
}

/// One row of suggestions on the home page (e.g. "NYT Best Sellers").
class SuggestionSection {
  final String title;
  final List<SuggestedBook> books;

  /// True when the data is built-in example data, not from the real source.
  final bool isSample;

  const SuggestionSection({
    required this.title,
    required this.books,
    this.isSample = false,
  });
}

/// A place book suggestions come from. Add a new class to add a new source.
abstract class SuggestionSource {
  String get title;

  /// Returns real suggestions, or an empty list / throws when the source is
  /// unavailable (the service then falls back to [sample]).
  Future<List<SuggestedBook>> fetch();

  List<SuggestedBook> get sample;
}

/// New York Times best-seller list.
/// Needs a free API key from developer.nytimes.com; without one the example
/// list is shown.
class NytBestSellersSource implements SuggestionSource {
  final String? apiKey;
  final String listName;
  final http.Client _client;

  NytBestSellersSource({
    this.apiKey,
    this.listName = 'combined-print-and-e-book-fiction',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  String get title => 'NYT Best Sellers';

  @override
  Future<List<SuggestedBook>> fetch() async {
    final key = apiKey;
    if (key == null || key.isEmpty) return [];
    final response = await _client
        .get(
          Uri.parse(
            'https://api.nytimes.com/svc/books/v3/lists/current/$listName.json?api-key=$key',
          ),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body);
    final books = data['results']?['books'];
    if (books is! List) return [];
    return [
      for (final b in books.take(10))
        SuggestedBook(
          title: _titleCase('${b['title'] ?? ''}'),
          author: '${b['author'] ?? ''}',
          isbn: b['primary_isbn13'] as String?,
          coverUrl: b['book_image'] as String?,
          blurb: b['description'] as String?,
        ),
    ];
  }

  static String _titleCase(String s) => s
      .toLowerCase()
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  List<SuggestedBook> get sample => const [
    SuggestedBook(title: 'Fourth Wing', author: 'Rebecca Yarros'),
    SuggestedBook(
      title: 'Tomorrow, and Tomorrow, and Tomorrow',
      author: 'Gabrielle Zevin',
    ),
    SuggestedBook(title: 'Demon Copperhead', author: 'Barbara Kingsolver'),
  ];
}

/// Luxor "best picks". Luxor has no public API, so this is a placeholder.
/// TODO: connect a real feed or page parser for the Luxor recommendations.
class LuxorBestPicksSource implements SuggestionSource {
  @override
  String get title => 'Luxor Best Picks';

  @override
  Future<List<SuggestedBook>> fetch() async => [];

  @override
  List<SuggestedBook> get sample => const [
    SuggestedBook(title: 'Válka s mloky', author: 'Karel Čapek'),
    SuggestedBook(
      title: 'Obsluhoval jsem anglického krále',
      author: 'Bohumil Hrabal',
    ),
    SuggestedBook(title: 'Žert', author: 'Milan Kundera'),
  ];
}

/// Collects suggestions from all sources for the home page.
class BookSuggestionsService {
  final List<SuggestionSource> sources;

  BookSuggestionsService({List<SuggestionSource>? sources})
    : sources = sources ?? [NytBestSellersSource(), LuxorBestPicksSource()];

  /// The one call the home page makes.
  Future<List<SuggestionSection>> fetchSuggestions() async {
    final sections = <SuggestionSection>[];
    for (final source in sources) {
      List<SuggestedBook> books = [];
      try {
        books = await source.fetch();
      } catch (_) {
        books = [];
      }
      if (books.isNotEmpty) {
        sections.add(SuggestionSection(title: source.title, books: books));
      } else {
        sections.add(
          SuggestionSection(
            title: source.title,
            books: source.sample,
            isSample: true,
          ),
        );
      }
    }
    return sections;
  }
}
