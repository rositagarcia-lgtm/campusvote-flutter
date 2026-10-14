import 'package:campusvote_flutter/features/auth/domain/entities/auth_role.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/auth_user.dart';
import 'package:campusvote_flutter/features/auth/presentation/state/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const student = AuthUser(
    id: 's1',
    email: 'estudiante@campusvote.edu.pe',
    role: AuthRole.student,
  );
  const jury = AuthUser(
    id: 'j1',
    email: 'jurado@campusvote.edu.pe',
    role: AuthRole.jury,
  );
  const teacher = AuthUser(
    id: 't1',
    email: 'docente@campusvote.edu.pe',
    role: AuthRole.teacher,
  );

  test('el estudiante no queda obligado a cambiar la contraseña', () {
    const state = AuthState(
      authenticated: true,
      mustChangePassword: true,
      user: student,
    );
    expect(state.forcesPasswordChange, isFalse);
  });

  test('el jurado con contraseña temporal sí queda obligado', () {
    const state = AuthState(
      authenticated: true,
      mustChangePassword: true,
      user: jury,
    );
    expect(state.forcesPasswordChange, isTrue);
  });

  test('el docente asignado como jurado conserva el cambio obligatorio', () {
    const state = AuthState(
      authenticated: true,
      mustChangePassword: true,
      user: teacher,
    );
    expect(state.forcesPasswordChange, isTrue);
  });
}
