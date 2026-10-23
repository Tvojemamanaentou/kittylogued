import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/utils/auth_validation.dart';

void main() {
  group('AuthValidation', () {
    test('validates email and phone identifiers by selected method', () {
      expect(
        AuthValidation.identifier('reader@example.com', isEmail: true),
        isNull,
      );
      expect(
        AuthValidation.identifier('not-an-email', isEmail: true),
        isNotNull,
      );
      expect(
        AuthValidation.identifier('+420 777 123 456', isEmail: false),
        isNull,
      );
      expect(AuthValidation.identifier('letters', isEmail: false), isNotNull);
    });

    test('requires a six-character password and a valid username', () {
      expect(AuthValidation.password('12345'), isNotNull);
      expect(AuthValidation.password('123456'), isNull);
      expect(AuthValidation.username('reader_1'), isNull);
      expect(AuthValidation.username('x'), isNotNull);
      expect(AuthValidation.username('bad name'), isNotNull);
    });
  });
}
