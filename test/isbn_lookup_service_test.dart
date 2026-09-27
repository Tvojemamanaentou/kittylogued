import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';

void main() {
  test('IsbnLookupService fetches book metadata and cover for an English ISBN via Open Library', () async {
    final service = IsbnLookupService();

    // George Orwell - 1984
    const testIsbn = '978-0-451-52493-5';
    final result = await service.lookupByIsbn(testIsbn);

    expect(result, isNotNull);
    final title = result!.title.toLowerCase();
    expect(title.contains('1984') || title.contains('eighty-four'), isTrue);
    expect(result.author.toLowerCase(), contains('george orwell'));
    expect(result.coverUrl, isNotNull);
    expect(result.coverUrl!, isNotEmpty);
  });

  test('IsbnLookupService fetches Czech publication and VuFind cover via Knihovny.cz fallback', () async {
    final service = IsbnLookupService();

    // Karel Čapek - R.U.R. (Omega / Knihy Dobrovský edition)
    const testIsbn = '978-80-277-1368-4';
    final result = await service.lookupByIsbn(testIsbn);

    expect(result, isNotNull);
    final title = result!.title.toLowerCase();
    expect(title, contains('r.u.r.'));

    final author = result.author.toLowerCase();
    expect(author.contains('čapek') || author.contains('capek'), isTrue);

    expect(result.coverUrl, isNotNull);
    expect(
      result.coverUrl!,
      contains('knihovny.cz/Cover/Show?isbn=9788027713684'),
    );
  });

  test('IsbnLookupService returns null gracefully for invalid, dummy, or empty input', () async {
    final service = IsbnLookupService();

    final emptyResult = await service.lookupByIsbn('');
    expect(emptyResult, isNull);

    final dummyResult = await service.lookupByIsbn('0000000000000');
    expect(dummyResult, isNull);

    final shortResult = await service.lookupByIsbn('123456');
    expect(shortResult, isNull);
  });
}
