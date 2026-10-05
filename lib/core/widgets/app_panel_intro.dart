import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'app_palette.dart';
import 'panel_hero_org_badge.dart';

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
  });

  final String organizationName;
  final String? organizationLogoUrl;
  final String title;
  final String subtitle;
  final int primaryValue;
  final String primaryLabel;
  final int secondaryValue;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = appMuted(isDark);
    final accent = theme.colorScheme.primary;
    final rule = appBorder(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            PanelHeroOrgBadge(
              name: organizationName,
              logoUrl: organizationLogoUrl,
              accent: accent,
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                organizationName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Semantics(
          header: true,
          child: Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: AppSpacing.l),
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: rule),
              bottom: BorderSide(color: rule),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _OverviewNumber(
                  value: primaryValue,
                  label: primaryLabel,
                  color: accent,
                ),
              ),
              Container(height: 40, width: 1, color: rule),
              Expanded(
                child: _OverviewNumber(
                  value: secondaryValue,
                  label: secondaryLabel,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewNumber extends StatelessWidget {
  const _OverviewNumber({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayLabel = value == 1 && label.endsWith('s')
        ? label.substring(0, label.length - 1)
        : label;
    return Semantics(
      label: '$value $displayLabel',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Flexible(
            child: Text(
              displayLabel,
              maxLines: 2,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
