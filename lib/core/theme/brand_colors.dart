import 'package:flutter/material.dart';

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
  Color get brandPrimarySoft =>
      Theme.of(this).colorScheme.primary.withValues(
            alpha: Theme.of(this).brightness == Brightness.dark ? 0.22 : 0.12,
          );

  /// Acento institucional (secundario de la marca).
  Color get brandSecondary => Theme.of(this).colorScheme.secondary;
}