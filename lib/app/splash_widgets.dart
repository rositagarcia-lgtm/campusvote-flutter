import 'package:flutter/material.dart';

import '../core/theme/app_dimensions.dart';
import '../core/widgets/app_logo.dart';
import '../core/widgets/app_palette.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key, required this.name});

  final String name;

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
                name,
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
    final muted = appMuted(isDark);

    return Semantics(
      button: true,
      label: '$title. $subtitle. $action',
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rMedium,
          side: BorderSide(color: appBorder(isDark)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: accent, size: AppDimensions.iconLarge),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded,
                        color: accent, size: AppDimensions.iconMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: [
                    Icon(actionIcon,
                        color: accent, size: AppDimensions.iconSmall),
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
