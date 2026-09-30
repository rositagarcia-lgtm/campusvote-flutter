import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/brand_colors.dart';
import 'app_palette.dart';

/// Tarjeta de acción: ícono sobre fondo tintado, título, descripción y
/// chevron. Superficie plana, sin sombra.
///
/// Unifica los accesos navegables de la app (seguridad, progreso, votar,
/// resultados) para que el patrón se lea igual en todos los paneles.
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.accent,
    this.trailingIcon = Icons.chevron_right_rounded,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Color de marca; si es nulo se usa el primario institucional.
  final Color? accent;

  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = appMuted(isDark);
    final brand = accent ?? context.brandPrimary;
    final tint = brand.withValues(alpha: isDark ? 0.16 : 0.10);

    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: appBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.touchTarget,
            height: AppDimensions.touchTarget,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: AppRadii.rMedium,
            ),
            child: Icon(
              icon,
              color: brand,
              size: AppDimensions.iconLarge,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ],
            ),
          ),
          Icon(trailingIcon, color: brand),
        ],
      ),
    );

    if (onTap == null) return card;

    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.rLarge,
          child: card,
        ),
      ),
    );
  }
}
