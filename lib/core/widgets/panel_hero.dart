import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/brand_colors.dart';

/// Encabezado de panel: banda con degradado de la marca, icono decorativo y
/// una insignia contadora. Da identidad visual a cada flujo (estudiante,
/// jurado, docente…).
class PanelHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;
  final String? badgeLabel;

  /// Logo (URL) y nombre de la organización, cuando ya se resolvieron.
  final String? organizationLogoUrl;
  final String? organizationName;

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

  @override
  Widget build(BuildContext context) {
    final primary = context.brandPrimary;
    final darkEdge = Color.lerp(primary, Colors.black, 0.22)!;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppRadii.rXLarge,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, darkEdge],
        ),
      ),
      child: Stack(
        children: [
          // Orbes decorativos translúcidos.
          Positioned(
            right: -28,
            top: -28,
            child: _orb(onPrimary, 0.10, 140),
          ),
          Positioned(
            right: 40,
            bottom: -36,
            child: _orb(onPrimary, 0.08, 110),
          ),
          // Watermark del icono del rol.
          Positioned(
            right: 14,
            bottom: -6,
            child: Icon(
              icon,
              size: 104,
              color: onPrimary.withValues(alpha: 0.10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: onPrimary.withValues(alpha: 0.16),
                        borderRadius: AppRadii.rMedium,
                      ),
                      child: Icon(icon, color: onPrimary, size: 26),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: onPrimary.withValues(alpha: 0.16),
                        borderRadius: AppRadii.rMedium,
                      ),
                      child: Text(
                        badgeLabel ?? title.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: onPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: onPrimary.withValues(alpha: 0.9),
                      ),
                ),
                if (organizationName != null && organizationName!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      if (organizationLogoUrl != null &&
                          organizationLogoUrl!.isNotEmpty)
                        Container(
                          width: 26,
                          height: 26,
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadii.rSmall,
                          ),
                          child: Image.network(
                            organizationLogoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        )
                      else
                        Icon(
                          Icons.account_balance_rounded,
                          size: AppDimensions.iconSmall,
                          color: onPrimary.withValues(alpha: 0.9),
                        ),
                      const SizedBox(width: AppSpacing.s),
                      Flexible(
                        child: Text(
                          organizationName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: onPrimary.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.m),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: onPrimary,
                    borderRadius: AppRadii.rMedium,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        badge,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color base, double alpha, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: base.withValues(alpha: alpha),
      ),
    );
  }
}