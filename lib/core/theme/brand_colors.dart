import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Colores derivados del color primario institucional.
///
/// El branding de la organización se resuelve como `ColorScheme.primary` del
/// tema; los componentes deben usar estas extensiones (no `AppColors.primary`,
/// que es el fallback estático) para que los colores de la organización se
/// apliquen en toda la app, claro y oscuro.
extension BrandColors on BuildContext {
  /// Color primario institucional (marca).
  Color get brandPrimary => Theme.of(this).colorScheme.primary;

  /// Fondo suave para chips/banners del color primario.
  Color get brandPrimarySoft => Theme.of(this).colorScheme.primary.withValues(
        alpha: Theme.of(this).brightness == Brightness.dark ? 0.22 : 0.12,
      );

  /// Acento institucional (secundario de la marca).
  Color get brandSecondary => Theme.of(this).colorScheme.secondary;

  /// Degradado de marca para cabeceras y héroes (primario → secundario).
  LinearGradient get brandGradient {
    final scheme = Theme.of(this).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        scheme.primary,
        Color.lerp(scheme.primary, scheme.secondary, 0.55)!,
      ],
    );
  }
}

/// Reglas de contraste WCAG para colores que llegan del backend.
///
/// Las organizaciones eligen libremente su color; la app no puede asumir que
/// sea legible sobre blanco, sobre el fondo oscuro ni con texto blanco encima.
class BrandContrast {
  const BrandContrast._();

  /// Relación de contraste WCAG 2.x entre dos colores (1–21).
  static double ratio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Tinta (oscura o clara) que más contrasta sobre [background].
  static Color onColor(Color background) =>
      ratio(background, AppColors.inkInverse) >=
              ratio(background, AppColors.ink)
          ? AppColors.inkInverse
          : AppColors.ink;

  /// Ajusta la luminosidad de [color] hasta alcanzar [minRatio] frente a
  /// [background] conservando el tono de la marca.
  ///
  /// Un azul marino institucional sobre el fondo oscuro, o un amarillo sobre
  /// blanco, se aclaran/oscurecen lo justo para ser legibles como texto e
  /// iconos sin dejar de reconocerse como el color de la organización.
  static Color ensure(Color color, Color background, {double minRatio = 3}) {
    if (ratio(color, background) >= minRatio) return color;
    final lighten = background.computeLuminance() < 0.5;
    final hsl = HSLColor.fromColor(color);
    var lightness = hsl.lightness;
    for (var i = 0; i < 20; i++) {
      lightness = (lightness + (lighten ? 0.04 : -0.04)).clamp(0.0, 1.0);
      final candidate = hsl.withLightness(lightness).toColor();
      if (ratio(candidate, background) >= minRatio) return candidate;
    }
    return hsl.withLightness(lightness).toColor();
  }
}
