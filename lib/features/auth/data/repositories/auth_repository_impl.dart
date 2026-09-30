import 'dart:io';

import '../../../../core/errors/result.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_interceptor.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_result.dart';
import '../../domain/entities/totp.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_profile_datasource.dart';
import 'auth_security_datasource.dart';
import 'auth_session_datasource.dart';

/// Persistencia ligera del usuario en local storage (no seguro: solo perfil).
abstract class AuthUserPersister {
  Future<void> persistUser(AuthUser user);
  Future<AuthUser?> readUser();
  Future<void> clearUser();
}

/// Implementación del [AuthRepository] que compone dos data sources:
/// - [AuthSessionDataSource]: login, loginTotp, refresh, profile, logout.
/// - [AuthSecurityDataSource]: 2FA (TOTP) + cambio de contraseña.
///
/// Implementa además [AuthRefresher] para que el [AuthInterceptor]
/// pueda renovar tokens durante un 401.
class AuthRepositoryImpl
    implements AuthRepository, AuthRefresher {
  AuthRepositoryImpl({
    required ApiClient client,
    required AuthUserPersister persister,
  })  : _session = AuthSessionDataSource(client, persister),
        _security = AuthSecurityDataSource(client),
        _profile = AuthProfileDataSource(client, persister);

  final AuthSessionDataSource _session;
  final AuthSecurityDataSource _security;
  final AuthProfileDataSource _profile;

  // ── Sesión ────────────────────────────────────────────────────
  @override
  Future<Result<LoginResult>> login({
    required String email,
    required String password,
  }) =>
      _session.login(email: email, password: password);

  @override
  Future<Result<LoginResult>> verifyLoginTotp({
    required String tempToken,
    required String code,
  }) =>
      _session.verifyLoginTotp(tempToken: tempToken, code: code);

  @override
  Future<Result<LoginResult>> requestEmailLogin({required String email}) =>
      _session.requestEmailLogin(email: email);

  @override
  Future<Result<LoginResult>> verifyEmailLogin({
    required String tempToken,
    required String code,
  }) =>
      _session.verifyEmailLogin(tempToken: tempToken, code: code);

  @override
  Future<bool> resendEmailLogin({required String tempToken}) =>
      _session.resendEmailLogin(tempToken: tempToken);

  @override
  Future<Result<TokenPair>> refresh({required String refreshToken}) =>
      _session.refresh(refreshToken: refreshToken);

  @override
  Future<bool> tryRefresh() async {
    final refreshToken = await _session.currentRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    final result = await _session.refresh(refreshToken: refreshToken);
    return result.isSuccess;
  }

  @override
  Future<Result<AuthUser>> getProfile() => _session.getProfile();

  @override
  Future<void> logout({String? refreshToken}) =>
      _session.logout(refreshToken: refreshToken);

  @override
  Future<AuthUser?> currentUser() => _session.currentUser();

  @override
  Future<bool> hasSession() => _session.hasSession();

  @override
  Future<void> persistSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  }) =>
      _session.persistSession(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

  @override
  Future<void> persistUser(AuthUser user) => _session.persistUser(user);

  @override
  Future<void> clearSession() => _session.clearSession();

  @override
  Future<String?> currentAccessToken() => _session.currentAccessToken();

  @override
  Future<String?> currentRefreshToken() => _session.currentRefreshToken();

  // ── 2FA + password ───────────────────────────────────────────
  @override
  Future<Result<TotpStatus>> getTwoFactorStatus() =>
      _security.getTwoFactorStatus();

  @override
  Future<Result<TotpSetup>> setupTotp() => _security.setupTotp();

  @override
  Future<Result<TotpEnableResult>> verifyAndEnableTotp(String code) =>
      _security.verifyAndEnableTotp(code);

  @override
  Future<Result<void>> disableTotp({required String password}) =>
      _security.disableTotp(password: password);

  @override
  Future<Result<void>> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _security.changeMyPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  // ── Perfil (foto y datos) ─────────────────────────────────────
  @override
  Future<Result<AuthUser>> updateProfile(Map<String, dynamic> fields) =>
      _profile.updateProfile(fields);

  @override
  Future<Result<AuthUser>> updateAvatar(File file) =>
      _profile.updateAvatar(file);
}