import 'dart:io';

import 'package:campusvote_flutter/core/branding/organization_branding.dart';
import 'package:campusvote_flutter/core/branding/organization_branding_repository.dart';
import 'package:campusvote_flutter/core/di/core_providers.dart';
import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/storage/local_storage.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/auth_user.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/login_result.dart';
import 'package:campusvote_flutter/features/auth/domain/entities/totp.dart';
import 'package:campusvote_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:campusvote_flutter/features/auth/presentation/state/auth_controller.dart';
import 'package:campusvote_flutter/features/auth/presentation/state/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _IdleAuthRepository implements AuthRepository {
  @override
  Future<Result<LoginResult>> login({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<LoginResult>> verifyLoginTotp({
    required String tempToken,
    required String code,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<LoginResult>> requestEmailLogin({required String email}) =>
      throw UnimplementedError();

  @override
  Future<Result<LoginResult>> verifyEmailLogin({
    required String tempToken,
    required String code,
  }) =>
      throw UnimplementedError();

  @override
  Future<bool> resendEmailLogin({required String tempToken}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> requestPasswordReset({required String email}) =>
      throw UnimplementedError();

  @override
  Future<Result<TokenPair>> refresh({required String refreshToken}) =>
      throw UnimplementedError();

  @override
  Future<Result<AuthUser>> getProfile() => throw UnimplementedError();

  @override
  Future<void> logout({String? refreshToken}) => throw UnimplementedError();

  @override
  Future<AuthUser?> currentUser() async => null;

  @override
  Future<bool> hasSession() async => false;

  @override
  Future<void> persistSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> persistUser(AuthUser user) => throw UnimplementedError();

  @override
  Future<void> clearSession() => throw UnimplementedError();

  @override
  Future<String?> currentAccessToken() async => null;

  @override
  Future<String?> currentRefreshToken() async => null;

  @override
  Future<Result<TotpStatus>> getTwoFactorStatus() => throw UnimplementedError();

  @override
  Future<Result<TotpSetup>> setupTotp() => throw UnimplementedError();

  @override
  Future<Result<TotpEnableResult>> verifyAndEnableTotp(String code) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> disableTotp({
    required String password,
    required String code,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<AuthUser>> updateProfile(Map<String, dynamic> fields) =>
      throw UnimplementedError();

  @override
  Future<Result<AuthUser>> updateAvatar(File file) =>
      throw UnimplementedError();
}

class _ScriptedBrandingRepository extends OrganizationBrandingRepository {
  _ScriptedBrandingRepository(this.results)
      : super(ApiClient(storage: SecureStorage()));

  final List<Result<OrganizationBranding>> results;
  int calls = 0;

  @override
  Future<Result<OrganizationBranding>> fetch(String organizationId) async {
    final index = calls++;
    return results[index < results.length ? index : results.length - 1];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const user = AuthUser(
    id: 'jurado-1',
    email: 'jurado@campusvote.test',
    role: 'JURY',
    organizationId: 'org-1',
  );

  Future<AuthController> controllerFor(
    _ScriptedBrandingRepository branding,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorage.create();
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(_IdleAuthRepository()),
        organizationBrandingRepositoryProvider.overrideWithValue(branding),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(authControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    controller.patch(const AuthState(
      initializing: false,
      authenticated: true,
      user: user,
    ));
    return controller;
  }

  test(
      'el poll se detiene tras 401 pero el reintento manual vuelve a consultar',
      () async {
    final branding = _ScriptedBrandingRepository(const [
      FailureResult(UnauthorizedFailure(code: 'INVALID_TOKEN')),
    ]);
    final controller = await controllerFor(branding);

    await controller.refreshBranding();
    await controller.refreshBranding();
    expect(branding.calls, 1);

    await controller.retryBranding();
    expect(branding.calls, 2);
  });

  test('el poll aplica backoff tras un fallo transitorio', () async {
    final branding = _ScriptedBrandingRepository(const [
      FailureResult(UnknownFailure(message: 'sin red')),
      FailureResult(UnknownFailure(message: 'sin red')),
    ]);
    final controller = await controllerFor(branding);

    await controller.refreshBranding(); // falla → 1 tick de espera
    await controller.refreshBranding(); // se omite
    expect(branding.calls, 1);

    await controller.refreshBranding(); // vuelve a intentar
    expect(branding.calls, 2);
  });

  test('un 403 también pausa el poll sin cerrar la sesión', () async {
    final branding = _ScriptedBrandingRepository(const [
      FailureResult(ForbiddenFailure(code: 'PASSWORD_CHANGE_REQUIRED')),
    ]);
    final controller = await controllerFor(branding);

    await controller.refreshBranding();
    await controller.refreshBranding();

    expect(branding.calls, 1);
    expect(controller.currentState.authenticated, isTrue);
  });
}
