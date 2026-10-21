part of '../app_theme.dart';

/// Paleta resuelta para un brillo y una organización concretos.
///
/// La marca CampusVote usa sus neutros fijos. Una organización, en cambio,
/// recibe neutros con un 3–4 % de su primario mezclado: el fondo "huele" a la
/// institución sin restar legibilidad, y su primario se corrige si no alcanza
/// contraste suficiente sobre la superficie (p. ej. azul marino en oscuro).
class _Palette {
  const _Palette({
    required this.brightness,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.border,
    required this.borderStrong,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
  });

  final Brightness brightness;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color border;
  final Color borderStrong;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;

  static _Palette resolve(OrganizationBranding? branding, Brightness b) {
    final isDark = b == Brightness.dark;
    final isOrg = branding != null && branding.id != 'campusvote';
    final rawPrimary = branding?.primaryColor ??
        (isDark ? AppColors.primaryLighter : AppColors.primary);
    final secondary = branding?.secondaryColor ?? AppColors.accent;

    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final background = isDark ? AppColors.darkBackground : AppColors.background;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final borderStrong =
        isDark ? AppColors.darkBorderStrong : AppColors.borderStrong;

    Color tint(Color base, double amount) => isOrg
        ? Color.alphaBlend(rawPrimary.withValues(alpha: amount), base)
        : base;

    // En claro la tarjeta sigue siendo blanca; en oscuro se tiñe con la marca.
    final resolvedSurface =
        isOrg && isDark ? tint(const Color(0xFF181C1F), 0.06) : surface;

    return _Palette(
      brightness: b,
      primary: BrandContrast.ensure(rawPrimary, resolvedSurface),
      secondary: secondary,
      background: isOrg
          ? tint(isDark ? const Color(0xFF0F1214) : const Color(0xFFF7F8FA),
              isDark ? 0.05 : 0.035)
          : background,
      surface: resolvedSurface,
      border: isOrg
          ? tint(
              isDark ? const Color(0xFF2A3034) : const Color(0xFFE3E7EC), 0.08)
          : border,
      borderStrong: isOrg
          ? tint(
              isDark ? const Color(0xFF3B4247) : const Color(0xFFCBD2DA), 0.08)
          : borderStrong,
      ink: isDark ? AppColors.darkInk : AppColors.ink,
      inkMuted: isDark ? AppColors.darkInkMuted : AppColors.inkMuted,
      inkFaint: isDark ? AppColors.darkInkFaint : AppColors.inkFaint,
    );
  }
}
