import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'app_palette.dart';
import 'panel_hero_org_badge.dart';

/// Encabezado de panel: tarjeta plana con el ícono del rol, sobretítulo,
/// título en serif con filete de color, contexto y el resumen del estado.
///
/// Da identidad a cada flujo (estudiante, jurado) sin decorar: sin degradados,
/// sin sombras y sin orbes; la jerarquía la llevan la tipografía y el filete.
class PanelHero extends StatelessWidget {
  const PanelHero({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
    this.badgeLabel,
    this.organizationLogoUrl,
    this.organizationName,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  /// Resumen del estado del panel (por ejemplo "3 ferias abiertas").
  final String badge;

  /// Sobretítulo explícito; si es nulo se usa el título en mayúsculas.
  final String? badgeLabel;

  /// Logo (URL) y nombre de la organización, cuando ya se resolvieron.
  final String? organizationLogoUrl;
  final String? organizationName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final brand = theme.colorScheme.primary;
    final muted = appMuted(isDark);
    final rule = appBorder(isDark);
    final tint = brand.withValues(alpha: isDark ? 0.16 : 0.10);
    final orgName = organizationName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(
                  (badgeLabel ?? title).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: brand,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'serif',
              fontWeight: FontWeight.w700,
              color: heroInk(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Container(width: 40, height: 3, color: brand),
          const SizedBox(height: AppSpacing.m),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: muted,
              height: 1.5,
            ),
          ),
          if (orgName != null && orgName.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Divider(height: 1, thickness: 1, color: rule),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                PanelHeroOrgBadge(
                  name: orgName,
                  logoUrl: organizationLogoUrl,
                  accent: brand,
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    orgName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          Divider(height: 1, thickness: 1, color: rule),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: AppDimensions.iconSmall,
                color: brand,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  badge,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
