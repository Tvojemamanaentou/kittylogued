import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';

void main() {
  test('IsbnLookupService fetches book metadata for a classic English ISBN via Open Library', () async {
    final service = IsbnLookupService();

    // George Orwell - 1984 / Nineteen Eighty-Four
    const testIsbn = '978-0-451-52493-5';
    final result = await service.lookupByIsbn(testIsbn);

    expect(result, isNotNull);
    final title = result!.title.toLowerCase();
    expect(title.contains('1984') || title.contains('eighty-four'), isTrue);
    expect(result.author.toLowerCase(), contains('george orwell'));
  });

  test('IsbnLookupService fetches regional Czech publication via Knihovny.cz fallback', () async {
    final service = IsbnLookupService();

    // Karel Čapek - R.U.R. (Omega / Knihy Dobrovský edition)
    const testIsbn = '978-80-277-1368-4';
    final result = await service.lookupByIsbn(testIsbn);

    expect(result, isNotNull);
    final title = result!.title.toLowerCase();
    expect(title, contains('r.u.r.'));

    final author = result.author.toLowerCase();
    expect(author.contains('čapek') || author.contains('capek'), isTrue);
  });

  test('IsbnLookupService returns null gracefully for invalid, dummy, or empty input', () async {
    final service = IsbnLookupService();

    // Empty string
    final emptyResult = await service.lookupByIsbn('');
    expect(emptyResult, isNull);

    // All-zero dummy sequence
    final dummyResult = await service.lookupByIsbn('0000000000000');
    expect(dummyResult, isNull);

    // Invalid character length
    final shortResult = await service.lookupByIsbn('123456');
    expect(shortResult, isNull);
  });
}
