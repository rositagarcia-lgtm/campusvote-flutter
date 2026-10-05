import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'app_status_chip.dart';
import '../../features/settings/presentation/settings_copy.dart';

/// Aviso inline con franja lateral de color: errores, advertencias, avisos
/// informativos y confirmaciones.
///
/// Reemplaza a los cuatro banners que tenía la app (error de acceso, nota de
/// contraseña, aviso de votación y aviso de rúbrica) para que el estado se
/// comunique siempre igual: franja de 4 px, ícono, fondo tintado y texto.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.message,
    this.tone = AppTone.danger,
    this.icon,
    this.liveRegion = false,
  });

  final String message;
  final AppTone tone;

  /// Ícono del aviso; si es nulo se toma según el tono.
  final IconData? icon;

  /// Marca el aviso como región viva para lectores de pantalla.
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tone = appToneColors(
      this.tone,
      isDark: isDark,
      primary: theme.colorScheme.primary,
    );
    final bg = _background(this.tone, isDark, tone.bg);
    final fg = tone.fg;
    final glyph = icon ?? _iconFor(this.tone);

    return Semantics(
      liveRegion: liveRegion,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.rMedium,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: fg),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(glyph, color: fg, size: AppDimensions.iconMedium),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          this.tone == AppTone.danger
                              ? SettingsCopy.of(context).error(message)
                              : SettingsCopy.of(context).t(message),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: fg,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fondo del aviso: los tonos con variante suave usan sus tokens; el resto
  /// usa el tinte del tono.
  Color _background(AppTone tone, bool isDark, Color tint) => switch (tone) {
        AppTone.danger =>
          isDark ? AppColors.darkDangerSoft : AppColors.dangerSoft,
        AppTone.warning =>
          isDark ? AppColors.darkWarningSoft : AppColors.warningSoft,
        AppTone.info => isDark ? AppColors.darkInfoSoft : AppColors.infoSoft,
        _ => tint,
      };

  IconData _iconFor(AppTone tone) => switch (tone) {
        AppTone.danger => Icons.error_outline_rounded,
        AppTone.warning => Icons.priority_high_rounded,
        AppTone.info => Icons.info_outline_rounded,
        AppTone.success => Icons.check_circle_outline_rounded,
        _ => Icons.info_outline_rounded,
      };
}
