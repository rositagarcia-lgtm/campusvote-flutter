import 'package:campusvote_flutter/features/auth/domain/entities/auth_role.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/auth_user.dart';
import 'package:campusvote_flutter/features/auth/presentation/state/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

AuthState _state({
  bool authenticated = false,
  String? role,
  String? tempToken,
  bool requiresEmailOtp = false,
  String? errorMessage,
}) {
  return AuthState(
    initializing: false,
    authenticated: authenticated,
    user: role == null
        ? null
        : AuthUser(
            id: '1',
            email: 'a@b.edu',
            firstName: 'Ana',
            lastName: 'Pérez',
            role: role,
          ),
    tempToken: tempToken,
    requiresEmailOtp: requiresEmailOtp,
    errorMessage: errorMessage,
  );
}

void main() {
  group('resolveJuryLoginOutcome', () {
    test('sesión de jurado: granted', () {
      final outcome = resolveJuryLoginOutcome(
        ok: true,
        state: _state(authenticated: true, role: AuthRole.jury),
      );
      expect(outcome, JuryLoginOutcome.granted);
    });

    test('cuenta de estudiante en el panel del jurado: notJury', () {
      final outcome = resolveJuryLoginOutcome(
        ok: true,
        state: _state(authenticated: true, role: AuthRole.student),
      );
      expect(outcome, JuryLoginOutcome.notJury);
    });

    test('sesión sin usuario (rol ausente): notJury, no granted', () {
      final outcome = resolveJuryLoginOutcome(ok: true, state: _state());
      expect(outcome, JuryLoginOutcome.notJury);
    });

    test('la cuenta exige código por correo: needsEmailCode', () {
      final outcome = resolveJuryLoginOutcome(
        ok: false,
        state: _state(tempToken: 'tmp', requiresEmailOtp: true),
      );
      expect(outcome, JuryLoginOutcome.needsEmailCode);
    });

    test('la cuenta exige 2FA: needsTotp', () {
      final outcome = resolveJuryLoginOutcome(
        ok: false,
        state: _state(tempToken: 'tmp'),
      );
      expect(outcome, JuryLoginOutcome.needsTotp);
    });

    test('credenciales incorrectas: failed con mensaje visible', () {
      final outcome = resolveJuryLoginOutcome(
        ok: false,
        state: _state(errorMessage: 'Credenciales inválidas'),
      );
      expect(outcome, JuryLoginOutcome.failed);
    });
  });
}
