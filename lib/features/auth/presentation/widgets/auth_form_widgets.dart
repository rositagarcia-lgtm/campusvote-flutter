import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_palette.dart';

/// Encabezado de acceso con marca compacta y título legible.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.accent,
    required this.icon,
    required this.overline,
    required this.title,
    required this.subtitle,
    this.logoSize = 64,
  });

  final Color accent;
  final IconData icon;
  final String overline;
  final String title;
  final String subtitle;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppMotion.reveal(
      0,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                image: true,
                label: 'Logo de CampusVote',
                // El logo entra con un leve rebote: la primera señal de que la
                // app respondió al toque del acceso.
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.7, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (_, s, child) =>
                      Transform.scale(scale: s, child: child),
                  child: AppLogo.asset(size: logoSize),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: AppDimensions.iconSmall, color: accent),
                    const SizedBox(width: AppSpacing.s),
                    Flexible(
                      child: Text(
                        overline,
                        maxLines: 2,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
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
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appMuted(isDark),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// Superficie que agrupa únicamente los campos del acceso.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Tarjeta sin elevación de Material: sombra difusa y una franja fina del
    // color del acceso arriba, que liga el formulario con su cabecera.
    return AppMotion.reveal(
      2,
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadii.rLarge,
          border: Border.all(color: appBorder(isDark)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.0 : 0.10),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 3, color: accent),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Mensaje de error inline con franja lateral.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({
    super.key,
    required this.message,
    this.title = 'Revisa la información',
    this.icon = PhosphorIconsRegular.warningCircle,
  });

  final String message;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shake(
      key: ValueKey(message),
      child: Semantics(
        liveRegion: true,
        label: '$title: $message',
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
                        Icon(icon,
                            color: AppColors.danger,
                            size: AppDimensions.iconMedium),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                message,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.danger,
                                  height: 1.4,
                                ),
                              ),
                            ],
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
    final muted = appMuted(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: appBorder(isDark)),
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
