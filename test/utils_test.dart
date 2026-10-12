import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/services/batch_import_queue.dart';
import 'package:kittylogued/utils/text_normalizer.dart';
import 'package:kittylogued/utils/uuid.dart';
import 'package:kittylogued/widgets/star_rating.dart';

void main() {
  test('normalizeText removes Czech diacritics and lowercases', () {
    expect(normalizeText('Čapek'), 'capek');
    expect(normalizeText('Válka s MLOKY'), 'valka s mloky');
  });

  test('newUuid has the version 4 format and is unique', () {
    final a = newUuid();
    final b = newUuid();
    expect(
      RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
          .hasMatch(a),
      isTrue,
    );
    expect(a, isNot(b));
  });

  test('BatchImportQueue.clean strips hyphens and upper-cases X', () {
    expect(BatchImportQueue.clean('978-80-257-0000-0'), '9788025700000');
    expect(BatchImportQueue.clean('80-7203-134-x'), '807203134X');
  });

  test('StarRating.label shows half stars', () {
    expect(StarRating.label(null), 'Not rated');
    expect(StarRating.label(9), '4.5');
    expect(StarRating.label(10), '5');
    expect(StarRating.label(1), '0.5');
  });
}
