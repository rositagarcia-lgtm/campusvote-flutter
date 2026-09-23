import 'package:campusvote_flutter/features/auth/data/models/auth_user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthUserModel.fromJson — formatUserResponse.js (snake_case)', () {
    test('parsea respuesta de /api/auth/me', () {
      final m = AuthUserModel.fromJson({
        'id': 'u1',
        'username': 'jperez',
        'email': 'jperez@uni.edu',
        'first_name': 'Juan',
        'last_name': 'Pérez',
        'role': 'STUDENT',
        'organization_id': 'org-1',
        'is_verified': true,
      });
      expect(m.id, 'u1');
      expect(m.email, 'jperez@uni.edu');
      expect(m.firstName, 'Juan');
      expect(m.lastName, 'Pérez');
      expect(m.role, 'STUDENT');
      expect(m.organizationId, 'org-1');
    });

    test('acepta camelCase como fallback', () {
      final m = AuthUserModel.fromJson({
        'id': 'u2',
        'email': 'a@b.c',
        'firstName': 'A',
        'lastName': 'B',
        'organizationId': 'org-2',
        'role': 'TEACHER',
      });
      expect(m.firstName, 'A');
      expect(m.organizationId, 'org-2');
    });
  });
}