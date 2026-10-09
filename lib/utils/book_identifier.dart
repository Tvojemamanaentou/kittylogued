import 'dart:math';

/// Utility generating unique, immutable, human-legible internal IDs.
/// Format: YYYYMM-slug-entropy-v0 (e.g., 202610-valkas-a8f1-v0)
class BookIdentifier {
  static final Random _random = Random.secure();

  static String generate({required String title}) {
    final now = DateTime.now();
    final yearMonth = '${now.year}${now.month.toString().padLeft(2, '0')}';

    // Normalize title to a 3- to 6-character clean slug
    var slug = title.trim().toLowerCase();
    const diacritics = {
      'á': 'a',
      'ä': 'a',
      'č': 'c',
      'ď': 'd',
      'é': 'e',
      'ě': 'e',
      'í': 'i',
      'ĺ': 'l',
      'ľ': 'l',
      'ň': 'n',
      'ó': 'o',
      'ö': 'o',
      'ô': 'o',
      'ŕ': 'r',
      'ř': 'r',
      'š': 's',
      'ť': 't',
      'ú': 'u',
      'ů': 'u',
      'ü': 'u',
      'ý': 'y',
      'ž': 'z',
    };
    diacritics.forEach((k, v) => slug = slug.replaceAll(k, v));
    slug = slug.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (slug.isEmpty) slug = 'book';
    if (slug.length > 6) slug = slug.substring(0, 6);

    // 4-character random hex entropy
    final entropy = _random.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0');

    return '$yearMonth-$slug-$entropy-v0';
  }
}
