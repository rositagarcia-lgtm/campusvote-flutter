part of 'auth_controller.dart';

/// Flujo de acceso del estudiante por correo (OTP EMAIL_PENDING).
extension AuthEmailLogin on AuthController {
  /// Acceso del ESTUDIANTE (paso 1): solicita el código OTP al correo y guarda
  /// el tempToken EMAIL_PENDING para el paso 2.
  ///
  /// El flujo con contraseña (jurado) usa [login] en su lugar.
  Future<bool> requestEmailLogin({required String email}) async {
    patch(currentState.copyWith(submitting: true, clearError: true));
    final result =
        await _ref.read(requestEmailLoginUseCaseProvider)(email: email);
    final data = result.when(
      success: (d) => d,
      failure: (f) {
        patch(currentState.copyWith(submitting: false, errorMessage: f.message));
        return null;
      },
    );
    if (data == null) return false;
    _applyBranding(data.organization);
    patch(currentState.copyWith(
      submitting: false,
      tempToken: data.tempToken,
      requiresEmailOtp: true,
      pendingEmail: data.email,
      pendingQrCode: data.qrCode,
      mustChangePassword: data.mustChangePassword,
      authenticated: false,
    ));
    return true;
  }

  /// Paso 2 del acceso del estudiante: verifica el código recibido por correo.
  Future<bool> verifyEmailLogin(String code) async {
    final temp = currentState.tempToken;
    if (temp == null || !currentState.requiresEmailOtp) {
      patch(currentState.copyWith(
        errorMessage: 'Inicia de nuevo: el código expiró',
        requiresEmailOtp: false,
        clearTempToken: true,
      ));
      return false;
    }
    patch(currentState.copyWith(submitting: true, clearError: true));
    final result = await _ref.read(verifyEmailLoginUseCaseProvider)(
        tempToken: temp, code: code);
    final data = result.when(
      success: (d) => d,
      failure: (f) {
        patch(currentState.copyWith(submitting: false, errorMessage: f.message));
        return null;
      },
    );
    if (data == null) return false;
    final user = await _ref.read(authRepositoryProvider).currentUser();
    patch(currentState.copyWith(
      submitting: false,
      authenticated: true,
      user: user,
      requiresEmailOtp: false,
      pendingEmail: null,
      clearPendingQrCode: true,
      mustChangePassword: data.mustChangePassword,
      clearTempToken: true,
    ));
    _hydrateProfile();
    return true;
  }

  /// Reenvía el código OTP del flujo del estudiante en curso.
  Future<bool> resendEmailLogin() async {
    final temp = currentState.tempToken;
    if (temp == null || !currentState.requiresEmailOtp) return false;
    patch(currentState.copyWith(clearError: true));
    if (!await _ref.read(authRepositoryProvider).resendEmailLogin(
          tempToken: temp,
        )) {
      patch(currentState.copyWith(errorMessage: 'No se pudo reenviar el código'));
      return false;
    }
    return true;
  }
}
