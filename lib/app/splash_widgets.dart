import 'package:flutter/material.dart';

import '../core/theme/app_dimensions.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_logo.dart';
import '../core/widgets/app_palette.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = appMuted(theme.brightness == Brightness.dark);
    return Row(
      children: [
        Semantics(
          image: true,
          label: 'Logo de CampusVote',
          child: AppLogo.asset(size: 56),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CampusVote',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Plataforma académica',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          overline.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
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
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

/// Cada perfil es un destino claro, con la acción indicada en texto.
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
    this.actionVariant = AppButtonVariant.primary,
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
  final AppButtonVariant actionVariant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = appMuted(isDark);
    final accentInk = accentForeground ?? accent;
    final iconSurface = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.2 : 0.09),
      theme.colorScheme.surface,
    );

    return Material(
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.rLarge,
        side: BorderSide(color: appBorder(isDark)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: iconSurface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                eyebrow.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accentInk,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconSurface,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child:
                      Icon(icon, color: accentInk, size: AppDimensions.iconLarge),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              label: action,
              icon: actionIcon,
              variant: actionVariant,
              backgroundColor: accent,
              foregroundColor: accent.computeLuminance() > 0.25
                  ? AppColors.ink
                  : AppColors.inkInverse,
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
