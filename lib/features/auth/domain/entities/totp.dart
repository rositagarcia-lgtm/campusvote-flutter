/// Resultado de iniciar setup de TOTP (antes de confirmar).
class TotpSetup {
  final String secret;
  final String uri;
  final String qrCodeDataUrl;
  const TotpSetup({
    required this.secret,
    required this.uri,
    required this.qrCodeDataUrl,
  });
}

/// Resultado de verificar y habilitar TOTP.
class TotpEnableResult {
  final String message;
  final List<String> backupCodes;
  const TotpEnableResult({required this.message, required this.backupCodes});
}

/// Estado actual del 2FA del usuario autenticado.
class TotpStatus {
  final bool enabled;
  final int backupCodesRemaining;
  const TotpStatus({
    required this.enabled,
    required this.backupCodesRemaining,
  });
}