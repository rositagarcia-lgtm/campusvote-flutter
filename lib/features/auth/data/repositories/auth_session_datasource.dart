import '../../../../core/branding/organization_branding.dart';
import '../../../../core/config/endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_result.dart';
import '../models/auth_user_model.dart';
import 'auth_repository_impl.dart';

/// Capa de datos para el ciclo de sesión: login, loginTotp, refresh,
/// profile, logout y limpieza local.
class AuthSessionDataSource {
  AuthSessionDataSource(this._client, this._persister);

  final ApiClient _client;
  final AuthUserPersister _persister;

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  Failure _failureFromApi(ApiResponse<dynamic> r) {
    final err = r.error;
    final message = err?.message ?? r.message ?? 'Error desconocido';
    return UnknownFailure(message: message, code: err?.code);
  }

  /// El flag llega en camelCase en el nivel superior (`/login`) pero en
  /// snake_case dentro de `user` (`formatUserResponse` →
  /// `must_change_password`), que es lo que devuelve `/email/login-verify`.
  /// Importa para el jurado: la contraseña que envía el administrador es
  /// temporal y debe forzarse su cambio.
  static bool _mustChangePassword(Map<String, dynamic> data) {
    final top = data['mustChangePassword'];
    if (top is bool) return top;
    final user = data['user'];
    if (user is Map) {
      final nested = user['must_change_password'] ?? user['mustChangePassword'];
      if (nested is bool) return nested;
    }
    return false;
  }

  /// QR opcional del paso de verificación por correo, como data URL
  /// `data:image/png;base64,...`.
  ///
  /// Acepta las dos grafías que usa el backend (`qrCode` en el modelo de TOTP,
  /// `qr_code` en los endpoints de sesión). Si no viene, se devuelve `null` y
  /// la pantalla de verificación omite la segunda vía.
  static String? _qrCode(Map<String, dynamic> data) {
    final raw = (data['qrCode'] ?? data['qr_code'] ?? '').toString().trim();
    return raw.isEmpty ? null : raw;
  }

  Future<Result<LoginResult>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.login,
        body: {'email': email, 'password': password},
      );
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success) return FailureResult(_failureFromApi(r));
      final data = r.data ?? <String, dynamic>{};
      if (data['requiresTotp'] == true) {
        return Success(LoginResult.totpPending(data['tempToken'] as String));
      }
      if (data['requiresOnboarding'] == true) {
        return Success(LoginResult.onboarding(data['tempToken'] as String));
      }
      // JURY / STUDENT / TEACHER: la contraseña es válida, pero el backend
      // exige además un código de un solo uso al correo y NO emite sesión
      // (`auth.session.service.js`: `if ([JURY, STUDENT, TEACHER].includes(role))
      // return { requiresEmailOtp: true, tempToken, ... }`). Sin esta rama el
      // cliente caía en "Respuesta inesperada del servidor".
      if (data['requiresEmailOtp'] == true) {
        final tempToken = data['tempToken'] as String?;
        if (tempToken == null) {
          return const FailureResult(UnknownFailure(
            message: 'Respuesta inesperada del servidor',
          ));
        }
        final org =
            data['organization'] is Map ? _asMap(data['organization']) : null;
        return Success(LoginResult.emailOtpPending(
          tempToken: tempToken,
          email: (data['email'] ?? email).toString(),
          mustChangePassword: _mustChangePassword(data),
          organization: org == null
              ? null
              : OrganizationBranding.fromOrganizationJson(org),
          qrCode: _qrCode(data),
        ));
      }
      // Sesión directa: solo SUPERADMIN (el resto de roles pasa por un
      // segundo factor antes de recibir `token`).
      final token = data['token'] as String?;
      final refresh = data['refreshToken'] as String?;
      if (token == null || refresh == null) {
        return const FailureResult(UnknownFailure(
          message: 'Respuesta inesperada del servidor',
        ));
      }
      final user = data['user'] is Map
          ? AuthUserModel.fromJson(_asMap(data['user']))
          : null;
      if (user != null) await _persister.persistUser(user);
      await _client.storage.writeAccessToken(token);
      await _client.storage.writeRefreshToken(refresh);
      return Success(LoginResult.ok(
        token: token,
        refreshToken: refresh,
        mustChangePassword: _mustChangePassword(data),
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<LoginResult>> verifyLoginTotp({
    required String tempToken,
    required String code,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.loginTotp,
        body: {'code': code},
        headers: {'Authorization': 'Bearer $tempToken'},
      );
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success) return FailureResult(_failureFromApi(r));
      final data = r.data ?? <String, dynamic>{};
      final token = data['token'] as String?;
      final refresh = data['refreshToken'] as String?;
      final user = data['user'] is Map
          ? AuthUserModel.fromJson(_asMap(data['user']))
          : null;
      if (token == null || refresh == null) {
        return const FailureResult(UnknownFailure(
          message: 'Respuesta inesperada del servidor',
        ));
      }
      if (user != null) await _persister.persistUser(user);
      await _client.storage.writeAccessToken(token);
      await _client.storage.writeRefreshToken(refresh);
      return Success(LoginResult.ok(
        token: token,
        refreshToken: refresh,
        mustChangePassword: _mustChangePassword(data),
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  /// Acceso del estudiante: solicita un código OTP al correo. El payload es
  /// solo `{email}` — el rol NO se envía: lo resuelve el backend a partir de la
  /// cuenta y lo devuelve en `user.role` al completar el acceso.
  /// La respuesta incluye el branding de la organización pre-login.
  Future<Result<LoginResult>> requestEmailLogin({required String email}) async {
    try {
      final res = await _client.post(
        ApiEndpoints.loginEmailRequest,
        body: {'email': email},
      );
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success) return FailureResult(_failureFromApi(r));
      final data = r.data ?? <String, dynamic>{};
      if (data['requiresEmailOtp'] != true) {
        return const FailureResult(UnknownFailure(
          message: 'El servidor no habilitó el acceso por correo',
        ));
      }
      final tempToken = data['tempToken'] as String?;
      if (tempToken == null) {
        return const FailureResult(UnknownFailure(
          message: 'Respuesta inesperada del servidor',
        ));
      }
      final org =
          data['organization'] is Map ? _asMap(data['organization']) : null;
      return Success(LoginResult.emailOtpPending(
        tempToken: tempToken,
        email: (data['email'] ?? email).toString(),
        mustChangePassword: _mustChangePassword(data),
        organization:
            org == null ? null : OrganizationBranding.fromOrganizationJson(org),
        qrCode: _qrCode(data),
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  /// Completa el login sin contraseña con el código recibido por correo.
  Future<Result<LoginResult>> verifyEmailLogin({
    required String tempToken,
    required String code,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.loginEmailVerify,
        body: {'code': code},
        headers: {'Authorization': 'Bearer $tempToken'},
      );
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success) return FailureResult(_failureFromApi(r));
      final data = r.data ?? <String, dynamic>{};
      final token = data['token'] as String?;
      final refresh = data['refreshToken'] as String?;
      final user = data['user'] is Map
          ? AuthUserModel.fromJson(_asMap(data['user']))
          : null;
      if (token == null || refresh == null) {
        return const FailureResult(UnknownFailure(
          message: 'Respuesta inesperada del servidor',
        ));
      }
      if (user != null) await _persister.persistUser(user);
      await _client.storage.writeAccessToken(token);
      await _client.storage.writeRefreshToken(refresh);
      return Success(LoginResult.ok(
        token: token,
        refreshToken: refresh,
        mustChangePassword: _mustChangePassword(data),
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  /// Reenvía el código OTP al correo.
  Future<bool> resendEmailLogin({required String tempToken}) async {
    try {
      final res = await _client.post(
        ApiEndpoints.loginEmailResend,
        headers: {'Authorization': 'Bearer $tempToken'},
      );
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      return r.success;
    } catch (_) {
      return false;
    }
  }

  Future<Result<TokenPair>> refresh({required String refreshToken}) async {
    try {
      final res = await _client.post(
        ApiEndpoints.refresh,
        body: {'refreshToken': refreshToken},
      );
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success || r.data == null) {
        return FailureResult(_failureFromApi(r));
      }
      final token = r.data!['token'] as String?;
      final newRefresh = r.data!['refreshToken'] as String?;
      if (token == null || newRefresh == null) {
        return const FailureResult(UnknownFailure(
          message: 'Respuesta inesperada al refrescar token',
        ));
      }
      await _client.storage.writeAccessToken(token);
      await _client.storage.writeRefreshToken(newRefresh);
      return Success(TokenPair(token: token, refreshToken: newRefresh));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<AuthUser>> getProfile() async {
    try {
      final res = await _client.get(ApiEndpoints.me);
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success) return FailureResult(_failureFromApi(r));
      final user = AuthUserModel.fromJson(r.data ?? const {});
      await _persister.persistUser(user);
      return Success(user.toEntity());
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<void> logout({String? refreshToken}) async {
    try {
      await _client.post(
        ApiEndpoints.logout,
        body: refreshToken != null ? {'refreshToken': refreshToken} : null,
      );
    } catch (_) {}
    await _client.storage.clearAll();
    await _persister.clearUser();
  }

  Future<AuthUser?> currentUser() => _persister.readUser();

  Future<bool> hasSession() async {
    final token = await _client.storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> persistSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _persister.persistUser(user);
    await _client.storage.writeAccessToken(accessToken);
    await _client.storage.writeRefreshToken(refreshToken);
  }

  Future<void> persistUser(AuthUser user) async {
    await _persister.persistUser(user);
  }

  Future<void> clearSession() async {
    await _client.storage.clearAll();
    await _persister.clearUser();
  }

  Future<String?> currentAccessToken() => _client.storage.readAccessToken();
  Future<String?> currentRefreshToken() => _client.storage.readRefreshToken();
}
