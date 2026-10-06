part of 'auth_controller.dart';

class AuthState {
  final bool initializing;
  final bool authenticated;
  final AuthUser? user;
  final bool submitting;
  final String? tempToken; // para 2FA / EMAIL_PENDING
  final bool requiresEmailOtp; // acceso sin contraseña (email + código)
  final String? pendingEmail; // correo del flujo OTP en curso
  final String? pendingQrCode; // QR opcional como segunda vía del OTP
  final String? errorMessage;
  final bool mustChangePassword;

  const AuthState({
    this.initializing = true,
    this.authenticated = false,
    this.user,
    this.submitting = false,
    this.tempToken,
    this.requiresEmailOtp = false,
    this.pendingEmail,
    this.pendingQrCode,
    this.errorMessage,
    this.mustChangePassword = false,
  });

  AuthState copyWith({
    bool? initializing,
    bool? authenticated,
    AuthUser? user,
    bool? submitting,
    String? tempToken,
    bool? requiresEmailOtp,
    String? pendingEmail,
    String? pendingQrCode,
    String? errorMessage,
    bool? mustChangePassword,
    bool clearTempToken = false,
    bool clearError = false,
    bool clearPendingQrCode = false,
  }) {
    return AuthState(
      initializing: initializing ?? this.initializing,
      authenticated: authenticated ?? this.authenticated,
      user: user ?? this.user,
      submitting: submitting ?? this.submitting,
      tempToken: clearTempToken ? null : (tempToken ?? this.tempToken),
      requiresEmailOtp: requiresEmailOtp ?? this.requiresEmailOtp,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      pendingQrCode:
          clearPendingQrCode ? null : (pendingQrCode ?? this.pendingQrCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}

/// Qué hacer tras un intento de acceso con contraseña en el panel de jurado.
///
/// El backend es la autoridad del rol: si la contraseña es válida pero la
/// cuenta no es de jurado, se cierra la sesión en vez de dejar al usuario
/// dentro de un panel ajeno.
enum JuryLoginOutcome {
  /// Sesión iniciada y la cuenta es de jurado.
  granted,

  /// Credenciales válidas pero la cuenta no es de jurado: hay que cerrar la
  /// sesión y avisar.
  notJury,

  /// La cuenta exige además un código enviado al correo.
  needsEmailCode,

  /// La cuenta exige el código de la app autenticadora.
  needsTotp,

  /// Credenciales incorrectas u otro error (ver `AuthState.errorMessage`).
  failed,
}

JuryLoginOutcome resolveJuryLoginOutcome({
  required bool ok,
  required AuthState state,
}) {
  if (ok) {
    return state.user?.role == AuthRole.jury
        ? JuryLoginOutcome.granted
        : JuryLoginOutcome.notJury;
  }
  if (state.tempToken == null) return JuryLoginOutcome.failed;
  return state.requiresEmailOtp
      ? JuryLoginOutcome.needsEmailCode
      : JuryLoginOutcome.needsTotp;
}
