part of 'auth_session_datasource.dart';

/// Login con contraseña y segundo factor TOTP.
extension AuthSessionLogin on AuthSessionDataSource {
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
          mustChangePassword: AuthSessionDataSource._mustChangePassword(data),
          organization: org == null
              ? null
              : OrganizationBranding.fromOrganizationJson(org),
          qrCode: AuthSessionDataSource._qrCode(data),
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
        mustChangePassword: AuthSessionDataSource._mustChangePassword(data),
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
        mustChangePassword: AuthSessionDataSource._mustChangePassword(data),
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  /// Acceso del estudiante: solicita un código OTP al correo. El payload es
  /// solo `{email}` — el rol NO se envía: lo resuelve el backend a partir de la
  /// cuenta y lo devuelve en `user.role` al completar el acceso.
  /// La respuesta incluye el branding de la organización pre-login.
}
