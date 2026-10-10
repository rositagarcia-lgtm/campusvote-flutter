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

part 'auth_session_datasource_login.dart';
part 'auth_session_datasource_email.dart';
part 'auth_session_datasource_store.dart';
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
      final data = r.data ?? const <String, dynamic>{};
      var user = AuthUserModel.fromJson(data).toEntity();
      // Versiones del backend anteriores no incluyen la foto en /me: si el
      // campo ni siquiera viene, se conserva la que ya estaba guardada en vez
      // de borrarla. Si viene vacío, manda el servidor.
      if (!data.containsKey('avatar_url') && !data.containsKey('avatarUrl')) {
        final previous = await _persister.readUser();
        if (previous?.id == user.id && previous?.avatarUrl != null) {
          user = user.copyWith(avatarUrl: previous!.avatarUrl);
        }
      }
      await _persister.persistUser(user);
      return Success(user);
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

}
