import 'package:campusvote_flutter/core/routing/role_landing.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/auth_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('landingPathForRole', () {
    test('JURY aterriza en sus ferias asignadas', () {
      expect(landingPathForRole(AuthRole.jury), '/jury');
    });

    test('STUDENT aterriza en la evaluación docente', () {
      expect(landingPathForRole(AuthRole.student), '/teaching');
    });

    test('los demás roles caen en la vista de docentes', () {
      expect(landingPathForRole(AuthRole.teacher), '/teaching');
      expect(landingPathForRole(AuthRole.admin), '/teaching');
    });

    test('un rol ausente no deja la app sin destino', () {
      expect(landingPathForRole(null), '/teaching');
      expect(landingPathForRole('UNKNOWN'), '/teaching');
    });
  });

  group('AuthRole.label', () {
    test('traduce los roles conocidos', () {
      expect(AuthRole.label(AuthRole.jury), 'Jurado');
      expect(AuthRole.label(AuthRole.teacher), 'Docente');
      expect(AuthRole.label(AuthRole.student), 'Estudiante');
      expect(AuthRole.label(AuthRole.admin), 'Administrador');
      expect(AuthRole.label(AuthRole.superAdmin), 'Super administrador');
    });

    test('cae en Miembro con rol null o desconocido', () {
      expect(AuthRole.label(null), 'Miembro');
      expect(AuthRole.label('ROOT'), 'Miembro');
    });
  });
}
