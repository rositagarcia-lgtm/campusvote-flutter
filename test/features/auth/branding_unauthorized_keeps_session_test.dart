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
import 'package:campusvote_flutter/features/auth/presentation/state/auth_events.dart';
import 'package:campusvote_flutter/features/auth/presentation/state/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
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
  Future<Result<AuthUser>> updateAvatar(File file) => throw UnimplementedError();
}

class _UnauthorizedBrandingRepository extends OrganizationBrandingRepository {
  _UnauthorizedBrandingRepository()
      : super(ApiClient(storage: SecureStorage()));

  @override
  Future<Result<OrganizationBranding>> fetch(String organizationId) async =>
      const FailureResult(UnauthorizedFailure(code: 'INVALID_TOKEN'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('un 401 de branding no cierra una sesión ya iniciada', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorage.create();
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        organizationBrandingRepositoryProvider
            .overrideWithValue(_UnauthorizedBrandingRepository()),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(authControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    const user = AuthUser(
      id: 'judge-1',
      email: 'juez@campusvote.test',
      firstName: 'Ana',
      role: 'JURY',
      organizationId: 'org-1',
    );
    controller.patch(const AuthState(
      initializing: false,
      authenticated: true,
      user: user,
    ));
    final logoutCount = container.read(authEventsProvider).logoutCount;

    await controller.refreshBranding();
    await controller.refreshBranding();

    expect(container.read(authControllerProvider).authenticated, isTrue);
    expect(container.read(authControllerProvider).user, same(user));
    expect(container.read(authEventsProvider).logoutCount, logoutCount);
  });
}
