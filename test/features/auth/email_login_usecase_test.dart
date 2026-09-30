import 'package:campusvote_flutter/core/branding/organization_branding.dart';
import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/login_result.dart';
import 'package:campusvote_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:campusvote_flutter/features/auth/domain/usecases/auth_usecases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements AuthRepository {
  String? requestedEmail;
  String? verifyToken;
  String? verifyCode;
  bool resendCalled = false;

  @override
  Future<Result<LoginResult>> requestEmailLogin({
    required String email,
  }) async {
    requestedEmail = email;
    return Success(LoginResult.emailOtpPending(
      tempToken: 'tmp',
      email: email,
      mustChangePassword: false,
      organization: OrganizationBranding.fromOrganizationJson({
        'id': 'org-1',
        'name': 'Mi Universidad',
        'logo': '',
        'primary_color': '#00695C',
        'secondary_color': '#D4AF37',
      }),
    ));
  }

  @override
  Future<Result<LoginResult>> verifyEmailLogin({
    required String tempToken,
    required String code,
  }) async {
    verifyToken = tempToken;
    verifyCode = code;
    return Success(LoginResult.ok(
      token: 't',
      refreshToken: 'r',
      mustChangePassword: false,
    ));
  }

  @override
  Future<bool> resendEmailLogin({required String tempToken}) async {
    resendCalled = true;
    return true;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RequestEmailLoginUseCase', () {
    test('rejects empty email', () async {
      final repo = _Repo();
      final result = await RequestEmailLoginUseCase(repo)(email: '   ');
      expect(result, isA<FailureResult<LoginResult>>());
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(repo.requestedEmail, isNull);
    });

    test('rejects malformed email', () async {
      final repo = _Repo();
      final result = await RequestEmailLoginUseCase(repo)(email: 'no-es-correo');
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(repo.requestedEmail, isNull);
    });

    test('lowercases and forwards email, exposes branding', () async {
      final repo = _Repo();
      final result = await RequestEmailLoginUseCase(repo)(
        email: '  Alumno@UniV.edu ',
      );
      expect(result.isSuccess, isTrue);
      expect(repo.requestedEmail, 'alumno@univ.edu');
      final data = result.dataOrNull;
      expect(data, isNotNull);
      expect(data!.requiresEmailOtp, isTrue);
      expect(data.tempToken, isNotNull);
      expect(data.organization, isNotNull);
      expect(data.organization!.name, 'Mi Universidad');
      expect(data.organization!.primaryColor, const Color(0xFF00695C));
    });
  });

  group('VerifyEmailLoginUseCase', () {
    test('rejects non-6-digit codes', () async {
      final repo = _Repo();
      final result = await VerifyEmailLoginUseCase(repo)(
        tempToken: 'tmp',
        code: '12',
      );
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('rejects codes with letters', () async {
      final repo = _Repo();
      final result = await VerifyEmailLoginUseCase(repo)(
        tempToken: 'tmp',
        code: '12ab56',
      );
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('forwards tempToken and trimmed code', () async {
      final repo = _Repo();
      final result = await VerifyEmailLoginUseCase(repo)(
        tempToken: 'tmp-123',
        code: '  123456 ',
      );
      expect(result.isSuccess, isTrue);
      expect(repo.verifyToken, 'tmp-123');
      expect(repo.verifyCode, '123456');
    });
  });

  test('resends keeps working through the repository', () async {
    final repo = _Repo();
    final ok = await repo.resendEmailLogin(tempToken: 'tmp');
    expect(ok, isTrue);
    expect(repo.resendCalled, isTrue);
  });
}