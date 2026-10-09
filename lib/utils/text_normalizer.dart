
/// Normalizes text for search: lowercases and strips Czech diacritics.
String normalizeText(String input) {
  if (input.isEmpty) return '';
  var s = input.toLowerCase();

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

  diacritics.forEach((k, v) => s = s.replaceAll(k, v));
  return s;
}
