// settings_row.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_icon_tile.dart';
import '../../../../core/widgets/app_palette.dart';

/// Fila de Configuración: mosaico de ícono, título, descripción y control.
///
/// Sirve igual para un interruptor que para un enlace, así que todas las filas
/// comparten alto, ritmo y jerarquía tipográfica. La descripción envuelve en
/// varias líneas en vez de recortarse: en 320 px con texto grande una sola
/// línea obligaría a perder la mitad del mensaje.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.accent,
    this.onTap,
  });

  final IconData icon;

  /// Color del mosaico; si es nulo se usa el primario institucional.
  final Color? accent;

  final String title;
  final String? subtitle;

  /// Interruptor, chevron o cualquier control al final de la fila.
  final Widget trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final brand = accent ?? theme.colorScheme.primary;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          AppIconTile(icon: icon, color: brand),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: appMuted(isDark)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          trailing,
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}