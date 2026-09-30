import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Tonos disponibles para chips y estados.
enum AppTone { neutral, primary, success, warning, danger, info }

/// Par de colores (fondo tintado, texto) de un tono, con variante oscura.
///
/// El fondo usa el alpha del sistema (0.10 en claro, 0.16 en oscuro). En modo
/// oscuro el color del tono se aclara hacia `AppColors.inkInverse` para no
/// perder contraste sobre superficie oscura; el tono neutral ya trae su
/// variante propia y no se aclara.
class AppToneColors {
  const AppToneColors({required this.bg, required this.fg});

  /// Fondo tintado del tono.
  final Color bg;

  /// Color del texto y del ícono del tono.
  final Color fg;
}

/// Resuelve el par (fondo tintado, texto) de un tono para el modo actual.
AppToneColors appToneColors(
  AppTone tone, {
  required bool isDark,
  Color? primary,
}) {
  if (tone == AppTone.neutral) {
    final fg = isDark ? AppColors.darkInkMuted : AppColors.inkMuted;
    return AppToneColors(
        bg: fg.withValues(alpha: isDark ? 0.16 : 0.10), fg: fg);
  }

  final base = switch (tone) {
    AppTone.primary => primary ?? AppColors.primary,
    AppTone.success => AppColors.success,
    AppTone.warning => AppColors.warning,
    AppTone.danger => AppColors.danger,
    AppTone.info => AppColors.info,
    AppTone.neutral => AppColors.inkMuted,
  };
  final fg =
      isDark ? Color.lerp(base, AppColors.inkInverse, 0.32) ?? base : base;
  return AppToneColors(bg: fg.withValues(alpha: isDark ? 0.16 : 0.10), fg: fg);
}

/// Chip de estado: punto indicador (o ícono) y texto en negrita sobre fondo
/// tintado con el color del tono.
///
/// El estado nunca se comunica solo con color: siempre lleva el ícono o el
/// punto y el texto del estado.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = AppTone.neutral,
    this.icon,
    this.showDot = false,
  });

  final String label;
  final AppTone tone;

  /// Ícono del estado; si es nulo y [showDot] es falso, no hay marcador.
  final IconData? icon;

  /// Muestra un punto de color en lugar de ícono.
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tone = appToneColors(
      this.tone,
      isDark: isDark,
      primary: theme.colorScheme.primary,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: AppRadii.rSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: AppDimensions.iconSmall, color: tone.fg)
          else if (showDot)
            Container(
              width: AppSpacing.s,
              height: AppSpacing.s,
              decoration: BoxDecoration(color: tone.fg, shape: BoxShape.circle),
            ),
          if (icon != null || showDot) const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: tone.fg,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
