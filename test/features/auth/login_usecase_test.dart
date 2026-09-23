import 'package:campusvote_flutter/features/auth/domain/usecases/auth_usecases.dart';
import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/login_result.dart';
import 'package:campusvote_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements AuthRepository {
  String? lastEmail;
  String? lastPassword;

  @override
  Future<Result<LoginResult>> login({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
    return Success(LoginResult.ok(
      token: 't',
      refreshToken: 'r',
      mustChangePassword: false,
    ));
  }

  // Sin este método, noSuchMethod no reconoce la llamada con parámetros
  // con nombre y la prueba del cambio de contraseña falla.
  @override
  Future<Result<void>> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  }) async =>
      const Success(null);

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('LoginUseCase', () {
    test('rejects empty email', () async {
      final repo = _Repo();
      final result = await LoginUseCase(repo)(
        email: '   ',
        password: 'abc',
      );
      expect(result, isA<FailureResult<LoginResult>>());
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('lowercases email and forwards', () async {
      final repo = _Repo();
      final result = await LoginUseCase(repo)(
        email: '  Foo@Bar.com ',
        password: 'abc',
      );
      expect(result.isSuccess, isTrue);
      expect(repo.lastEmail, 'foo@bar.com');
      expect(repo.lastPassword, 'abc');
    });
  });

  group('VerifyLoginTotpUseCase', () {
    test('rejects non-6-digit codes', () async {
      final repo = _Repo();
      final result = await VerifyLoginTotpUseCase(repo)(
        tempToken: 't',
        code: '12',
      );
      expect(result.failureOrNull, isA<ValidationFailure>());
    });
  });

  group('ChangePasswordUseCase', () {
    test('rejects empty current password', () async {
      final repo = _Repo();
      final useCase = ChangePasswordUseCase(repo);
      final res = await useCase(currentPassword: '', newPassword: 'Abcdef1!');
      expect(res.failureOrNull, isA<ValidationFailure>());
    });

    test('rejects weak new password (no special char)', () async {
      final repo = _Repo();
      final useCase = ChangePasswordUseCase(repo);
      final res = await useCase(
        currentPassword: 'oldPass12',
        newPassword: 'Abcdefgh',
      );
      expect(res.failureOrNull, isA<ValidationFailure>());
    });

    test('accepts strong password', () async {
      final repo = _Repo();
      final useCase = ChangePasswordUseCase(repo);
      final res = await useCase(
        currentPassword: 'oldPass12',
        newPassword: 'Abcdef1!',
      );
      expect(res.isSuccess, isTrue);
    });
  });
}