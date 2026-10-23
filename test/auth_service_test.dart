import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/auth/auth_models.dart';
import 'package:kittylogued/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores the existing persisted user key', () async {
    const user = AuthUser(
      id: 'user-123',
      provider: AuthProviderType.email,
      email: 'reader@example.com',
    );
    SharedPreferences.setMockInitialValues({
      'authUser': jsonEncode(user.toJson()),
    });

    final service = await AuthService.load();

    expect(service.isSignedIn, isTrue);
    expect(service.user?.id, user.id);
    expect(service.user?.email, user.email);
  });
}
