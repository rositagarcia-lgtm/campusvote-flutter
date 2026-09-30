import '../../../../core/branding/organization_branding.dart';

/// Resultado de un intento de login.
///
/// Soporta los flujos del backend:
/// - 2FA requerido → `requiresTotp = true`, `tempToken` no nulo
/// - OTP por correo requerido (acceso sin contraseña) → `requiresEmailOtp = true`
/// - Onboarding 2FA pendiente → `requiresOnboarding = true`
/// - Login directo → `requiresTotp = false`, `token` no nulo
class LoginResult {
  final bool requiresTotp;
  final bool requiresOnboarding;
  final bool requiresEmailOtp;
  final String? tempToken;
  final String? email;
  final OrganizationBranding? organization;
  final String? token;
  final String? refreshToken;
  final bool mustChangePassword;

  /// Código QR como data URL `data:image/png;base64,...` para el paso de
  /// verificación del correo. Es opcional: si el backend no lo envía, la
  /// pantalla de verificación solo ofrece el código escrito y el reenvío.
  final String? qrCode;

  const LoginResult({
    this.requiresTotp = false,
    this.requiresOnboarding = false,
    this.requiresEmailOtp = false,
    this.tempToken,
    this.email,
    this.organization,
    this.token,
    this.refreshToken,
    this.mustChangePassword = false,
    this.qrCode,
  });

  factory LoginResult.totpPending(String tempToken) =>
      LoginResult(requiresTotp: true, tempToken: tempToken);

  factory LoginResult.onboarding(String tempToken) => LoginResult(
        requiresTotp: false,
        requiresOnboarding: true,
        tempToken: tempToken,
      );

  /// Acceso sin contraseña: se envió un código al correo y el login queda en
  /// espera del OTP. La respuesta trae el branding de la organización para
  /// pintar el splash/OTP con la identidad de la institución, y opcionalmente
  /// un QR como segunda vía de verificación.
  factory LoginResult.emailOtpPending({
    required String tempToken,
    required String email,
    required bool mustChangePassword,
    OrganizationBranding? organization,
    String? qrCode,
  }) {
    return LoginResult(
      requiresEmailOtp: true,
      tempToken: tempToken,
      email: email,
      organization: organization,
      mustChangePassword: mustChangePassword,
      qrCode: qrCode,
    );
  }

  factory LoginResult.ok({
    required String token,
    required String refreshToken,
    required bool mustChangePassword,
  }) {
    return LoginResult(
      requiresTotp: false,
      token: token,
      refreshToken: refreshToken,
      mustChangePassword: mustChangePassword,
    );
  }
}

/// Resultado del refresh.
class TokenPair {
  final String token;
  final String refreshToken;
  const TokenPair({required this.token, required this.refreshToken});
}
