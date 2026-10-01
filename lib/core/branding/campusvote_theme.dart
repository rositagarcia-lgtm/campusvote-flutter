import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fuerza la identidad de CampusVote dentro de una subpantalla.
///
/// El tema global se repinta con los colores de la organización en cuanto el
/// backend la resuelve, pero pre-login el usuario todavía está entrando a
/// CampusVote: el logo y los colores son los de la app, no los del tenant.
/// Este wrapper sobrescribe el `ColorScheme` y los botones con la paleta fija
/// para que el splash y los accesos no cambien de color según quién haya
/// iniciado sesión antes.
class CampusVoteTheme extends StatelessWidget {
  const CampusVoteTheme({
    super.key,
    required this.child,
    this.accent = AppColors.primary,
  });

  final Widget child;

  /// Color de la acción principal de la pantalla: verde para el estudiante,
  /// dorado para el jurado.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    // El dorado es claro: necesita tinta oscura encima, el verde no.
    final onAccent =
        accent.computeLuminance() > 0.52 ? AppColors.ink : AppColors.inkInverse;
    final scheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: scheme.copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.primary.computeLuminance() > 0.52
              ? AppColors.ink
              : AppColors.inkInverse,
          secondary: AppColors.accent,
          onSecondary: AppColors.ink,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: onAccent,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(foregroundColor: accent),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: accent),
        ),
      ),
      child: child,
    );
  }
}
