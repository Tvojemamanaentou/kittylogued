import 'dart:math';

final Random _uuidRandom = Random.secure();

/// Random (version 4) UUID, e.g. 3f2b8c1e-9d4a-4e7b-a1c2-5b6d7e8f9a0b.
/// Used as the stable id of books and users so they can be synced later.
String newUuid() {
  final bytes = List<int>.generate(16, (_) => _uuidRandom.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10xx
  String hex(int b) => b.toRadixString(16).padLeft(2, '0');
  final h = bytes.map(hex).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}
