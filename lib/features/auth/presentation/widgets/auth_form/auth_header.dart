import 'package:flutter/material.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_logo.dart';
import '../../../../../core/widgets/app_motion.dart';
import '../../../../../core/widgets/app_palette.dart';

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
