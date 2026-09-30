import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/widgets/app_logo.dart';

/// Encabezado institucional: logo, nombre y descriptor con filete.
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkInkMuted : AppColors.inkMuted;
    final accent = isDark ? AppColors.primaryLighter : AppColors.primary;

    return Column(
      children: [
        Semantics(
          image: true,
          label: 'Logo de CampusVote',
          child: AppLogo.asset(size: 96),
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: isDark ? AppColors.darkInk : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Container(width: 40, height: 3, color: accent),
        const SizedBox(height: AppSpacing.m),
        Text(
          'VOTACIÓN Y EVALUACIÓN ACADÉMICA',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: muted,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

/// Título de sección con sobretítulo en mayúsculas y filete inferior.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.overline,
    required this.title,
    required this.subtitle,
  });

  final String overline;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkInkMuted : AppColors.inkMuted;
    final accent = isDark ? AppColors.primaryLighter : AppColors.primary;
    final rule = isDark ? AppColors.darkBorder : AppColors.primarySoft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          overline.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: accent,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: AppSpacing.m),
        Divider(height: 1, thickness: 1, color: rule),
      ],
    );
  }
}

/// Tarjeta de acceso plana, con franja lateral de color y pie de acción.
class AccessCard extends StatelessWidget {
  const AccessCard({
    super.key,
    required this.icon,
    required this.actionIcon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final IconData actionIcon;
  final Color accent;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkInkMuted : AppColors.inkMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.primarySoft;
    final tint = accent.withValues(alpha: isDark ? 0.14 : 0.08);

    return Semantics(
      button: true,
      label: '$title. $subtitle. $action',
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLarge,
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: tint,
          highlightColor: tint,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: tint,
                                borderRadius: AppRadii.rMedium,
                              ),
                              child: Icon(
                                icon,
                                color: accent,
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
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    subtitle,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: muted,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Divider(height: 1, thickness: 1, color: border),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          children: [
                            Icon(actionIcon,
                                size: AppDimensions.iconMedium, color: accent),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: Text(
                                action,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_rounded,
                                size: AppDimensions.iconMedium, color: accent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
