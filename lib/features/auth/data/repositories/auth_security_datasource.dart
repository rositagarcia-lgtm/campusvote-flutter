import '../../../../core/config/endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/totp.dart';
import '../models/totp_models.dart';

/// Capa de datos para 2FA (TOTP) + cambio de contraseña.
class AuthSecurityDataSource {
  AuthSecurityDataSource(this._client);
  final ApiClient _client;

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

  Future<Result<TotpStatus>> getTwoFactorStatus() async {
    try {
      final res = await _client.get(ApiEndpoints.totpStatus);
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success || r.data == null) {
        return FailureResult(_failureFromApi(r));
      }
      return Success(TotpStatusModel.fromJson(r.data!).toEntity());
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<TotpSetup>> setupTotp() async {
    try {
      final res = await _client.post(ApiEndpoints.totpSetup);
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success || r.data == null) {
        return FailureResult(_failureFromApi(r));
      }
      return Success(TotpSetupModel.fromJson(r.data!).toEntity());
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<TotpEnableResult>> verifyAndEnableTotp(String code) async {
    try {
      final res = await _client.post(
        ApiEndpoints.totpVerify,
        body: {'code': code},
      );
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success || r.data == null) {
        return FailureResult(_failureFromApi(r));
      }
      return Success(TotpEnableResultModel.fromJson(r.data!).toEntity());
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<void>> disableTotp({required String password}) async {
    try {
      final res = await _client.post(
        ApiEndpoints.totpDisable,
        body: {'password': password},
      );
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success) return FailureResult(_failureFromApi(r));
      return const Success(null);
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<void>> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.changeMyPassword,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success) return FailureResult(_failureFromApi(r));
      return const Success(null);
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }
}