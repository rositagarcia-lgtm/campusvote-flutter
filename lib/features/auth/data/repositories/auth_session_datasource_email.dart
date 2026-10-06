part of 'auth_session_datasource.dart';

/// Acceso por correo sin contraseña (OTP).
extension AuthSessionEmail on AuthSessionDataSource {
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
        mustChangePassword: AuthSessionDataSource._mustChangePassword(data),
        organization:
            org == null ? null : OrganizationBranding.fromOrganizationJson(org),
        qrCode: AuthSessionDataSource._qrCode(data),
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<void>> requestPasswordReset({required String email}) async {
    try {
      final res = await _client.post(
        ApiEndpoints.passwordResetRequest,
        body: {'email': email},
      );
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success || r.data?['requested'] != true) {
        return FailureResult(_failureFromApi(r));
      }
      return const Success(null);
    } catch (error) {
      return FailureResult(mapExceptionToFailure(error));
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
        mustChangePassword: AuthSessionDataSource._mustChangePassword(data),
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

}
