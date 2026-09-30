import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_logo.dart';

Color _muted(bool isDark) =>
    isDark ? AppColors.darkInkMuted : AppColors.inkMuted;

Color _border(bool isDark) =>
    isDark ? AppColors.darkBorder : AppColors.primarySoft;

/// Encabezado institucional reutilizable: logo, sobretítulo del rol, título,
/// filete de color y subtítulo.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.accent,
    required this.icon,
    required this.overline,
    required this.title,
    required this.subtitle,
  });

  final Color accent;
  final IconData icon;
  final String overline;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Semantics(
          image: true,
          label: 'Logo de CampusVote',
          // Pre-login la identidad es la de CampusVote, no la del tenant.
          child: AppLogo.asset(size: 80),
        ),
        const SizedBox(height: AppSpacing.l),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppDimensions.iconSmall, color: accent),
            const SizedBox(width: AppSpacing.s),
            Text(
              overline.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'serif',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Container(width: 40, height: 3, color: accent),
        const SizedBox(height: AppSpacing.m),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: _muted(isDark),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// Tarjeta plana con filete superior de color que agrupa el formulario.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.rLarge,
        side: BorderSide(color: _border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: accent),
          Padding(padding: const EdgeInsets.all(AppSpacing.l), child: child),
        ],
      ),
    );
  }
}

/// Mensaje de error inline con franja lateral.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      liveRegion: true,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkDangerSoft : AppColors.dangerSoft,
          borderRadius: AppRadii.rMedium,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: AppColors.danger),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.danger,
                          size: AppDimensions.iconMedium),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.danger,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nota informativa al pie de la tarjeta, separada por un divisor.
class AuthInfoNote extends StatelessWidget {
  const AuthInfoNote({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = _muted(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: _border(isDark)),
        const SizedBox(height: AppSpacing.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppDimensions.iconMedium, color: muted),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: muted,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
