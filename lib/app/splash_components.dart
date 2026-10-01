import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_logo.dart';

/// Encabezado institucional de la pantalla de bienvenida.
class SplashWelcomeHeader extends StatelessWidget {
  const SplashWelcomeHeader({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Semantics(
          image: true,
          label: 'Logo de CampusVote',
          child: AppLogo.asset(size: AppDimensions.brandLogoLarge),
        ),
        const SizedBox(height: AppSpacing.m),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            borderRadius: AppRadii.rXLarge,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.darkPrimarySoft, AppColors.darkSurface]
                  : [AppColors.primarySoft, AppColors.primarySubtle],
            ),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.primarySoft,
            ),
          ),
          child: Column(
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkInk : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Votación y evaluación académica',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkInkMuted : AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de acceso para cada perfil académico.
class SplashAccessCard extends StatelessWidget {
  const SplashAccessCard({
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
    final tint = accent.withValues(alpha: isDark ? 0.14 : 0.08);

    return AppCard(
      onTap: onTap,
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.l),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppDimensions.splashIconTile,
                height: AppDimensions.splashIconTile,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: AppRadii.rLarge,
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: AppDimensions.iconLarge + AppSpacing.xs,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: accent,
                size: AppDimensions.iconSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkInkMuted : AppColors.inkMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: AppRadii.rMedium,
            ),
            child: Row(
              children: [
                Icon(actionIcon, size: AppDimensions.iconMedium, color: accent),
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
                Icon(
                  Icons.arrow_forward_rounded,
                  color: accent,
                  size: AppDimensions.iconMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
