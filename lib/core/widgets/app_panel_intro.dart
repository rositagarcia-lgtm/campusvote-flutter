import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_dimensions.dart';
import 'app_palette.dart';
import 'panel_hero_org_badge.dart';
import 'panel_overview_number.dart';

/// Encabezado de trabajo para los paneles del jurado y del estudiante.
/// La identidad de la organización viene del branding cargado en la sesión.
class AppPanelIntro extends StatelessWidget {
  const AppPanelIntro({
    super.key,
    required this.organizationName,
    required this.title,
    required this.subtitle,
    required this.primaryValue,
    required this.primaryLabel,
    required this.secondaryValue,
    required this.secondaryLabel,
    this.organizationLogoUrl,
    this.showProductName = true,
    this.showOrganizationHeader = true,
    this.contextLabel,
    this.tertiaryValue,
    this.tertiaryLabel,
  });

  final String organizationName;
  final String? organizationLogoUrl;
  final String title;
  final String subtitle;
  final int primaryValue;
  final String primaryLabel;
  final int secondaryValue;
  final String secondaryLabel;
  final bool showProductName;
  final bool showOrganizationHeader;
  final String? contextLabel;
  final int? tertiaryValue;
  final String? tertiaryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = appMuted(isDark);
    final accent = theme.colorScheme.primary;
    final rule = appBorder(isDark);
    final surface = theme.colorScheme.surface;
    final introSurface = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.16 : 0.055),
      surface,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: introSurface,
        borderRadius: AppRadii.rXLarge,
        border:
            Border.all(color: accent.withValues(alpha: isDark ? 0.28 : 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showOrganizationHeader) ...[
            Row(
              children: [
                PanelHeroOrgBadge(
                  name: organizationName,
                  logoUrl: organizationLogoUrl,
                  accent: accent,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showProductName) ...[
                        Text(
                          'CAMPUSVOTE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      Text(
                        organizationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: contextLabel == null ? AppSpacing.xl : AppSpacing.l,
            ),
          ],
          if (contextLabel != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: AppRadii.rMedium,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIconsRegular.shieldCheck,
                        size: AppDimensions.iconSmall, color: accent),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        contextLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.35,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(height: 1, color: rule),
          const SizedBox(height: AppSpacing.l),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PanelOverviewNumber(
                  value: primaryValue,
                  label: primaryLabel,
                  color: accent,
                  compact: tertiaryValue != null,
                ),
              ),
              Container(height: 44, width: 1, color: rule),
              Expanded(
                child: PanelOverviewNumber(
                  value: secondaryValue,
                  label: secondaryLabel,
                  color: theme.colorScheme.onSurface,
                  compact: tertiaryValue != null,
                ),
              ),
              if (tertiaryValue != null && tertiaryLabel != null) ...[
                Container(height: 44, width: 1, color: rule),
                Expanded(
                  child: PanelOverviewNumber(
                    value: tertiaryValue!,
                    label: tertiaryLabel!,
                    color: theme.colorScheme.onSurfaceVariant,
                    compact: true,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
