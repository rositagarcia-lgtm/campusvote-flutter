import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/brand_colors.dart';

/// Opción de acceso: franja lateral con el color del perfil, encabezado con
/// ícono, descripción y una fila de acción explícita. Toda la tarjeta es
/// tocable, pero la acción se lee en texto para no depender del color.
class AccessCard extends StatelessWidget {
  const AccessCard({
    super.key,
    required this.icon,
    required this.actionIcon,
    required this.accent,
    this.accentForeground,
    this.eyebrow = 'ACCESO',
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final IconData actionIcon;
  final Color accent;
  final Color? accentForeground;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accentInk = isDark
        ? BrandContrast.ensure(accent, scheme.surface, minRatio: 4.5)
        : (accentForeground ?? accent);
    final tile = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.22 : 0.10),
      scheme.surface,
    );

    return Material(
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.rLarge,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: accent),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.l,
                AppSpacing.l,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: tile,
                          borderRadius: AppRadii.rMedium,
                        ),
                        alignment: Alignment.center,
                        child: Icon(icon, color: accentInk, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eyebrow.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: accentInk,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Semantics(
                              header: true,
                              child: Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Divider(height: 1, color: scheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                    child: Row(
                      children: [
                        Icon(actionIcon, size: 18, color: accentInk),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Text(
                            action,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: accentInk,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          PhosphorIconsBold.arrowRight,
                          size: 18,
                          color: accentInk,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
