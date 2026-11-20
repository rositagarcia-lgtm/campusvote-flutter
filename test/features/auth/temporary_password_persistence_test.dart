import 'package:campusvote_flutter/core/storage/local_storage.dart';
import 'package:campusvote_flutter/features/auth/data/datasources/auth_user_persister.dart';
import 'package:campusvote_flutter/features/auth/data/models/auth_user_model.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la obligación de cambiar la clave sobrevive al reinicio', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorage.create();
    final persister = SharedPrefsAuthUserPersister(storage);

    await persister.persistUser(const AuthUser(
      id: 'jurado-1',
      email: 'jurado@campusvote.test',
      role: 'JURY',
      mustChangePassword: true,
    ));

    final restored = await persister.readUser();
    expect(restored, isNotNull);
    expect(restored!.mustChangePassword, isTrue);
  });

  test('el flag anidado en user también se parsea', () {
    final model = AuthUserModel.fromJson({
      'id': 'jurado-2',
      'email': 'jurado2@campusvote.test',
      'role': 'JURY',
      'user': {'must_change_password': true},
    });
    expect(model.mustChangePassword, isTrue);
  });
}
