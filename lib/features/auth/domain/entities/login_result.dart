/// Resultado de un intento de login.
///
/// Soporta los flujos del backend:
/// - 2FA requerido → `requiresTotp = true`, `tempToken` no nulo
/// - Onboarding 2FA pendiente → `requiresOnboarding = true`
/// - Login directo → `requiresTotp = false`, `token` no nulo
class LoginResult {
  final bool requiresTotp;
  final bool requiresOnboarding;
  final String? tempToken;
  final String? token;
  final String? refreshToken;
  final bool mustChangePassword;

  const LoginResult({
    required this.requiresTotp,
    this.requiresOnboarding = false,
    this.tempToken,
    this.token,
    this.refreshToken,
    this.mustChangePassword = false,
  });

  factory LoginResult.totpPending(String tempToken) =>
      LoginResult(requiresTotp: true, tempToken: tempToken);

  factory LoginResult.onboarding(String tempToken) => LoginResult(
        requiresTotp: false,
        requiresOnboarding: true,
        tempToken: tempToken,
      );

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