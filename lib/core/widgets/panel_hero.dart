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
                      _OrgBadge(
                        logoUrl: organizationLogoUrl,
                        name: organizationName!,
                        onPrimary: onPrimary,
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

/// Identidad de la organización dentro del panel.
///
/// Muestra el logo institucional y, si la organización todavía no tiene logo
/// o la URL falla, cae a sus iniciales: el panel nunca queda sin identidad.
class _OrgBadge extends StatelessWidget {
  const _OrgBadge({
    required this.logoUrl,
    required this.name,
    required this.onPrimary,
  });

  final String? logoUrl;
  final String name;
  final Color onPrimary;

  static String _initials(String value) {
    final words =
        value.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = logoUrl;
    return Container(
      width: 28,
      height: 28,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.rSmall,
      ),
      clipBehavior: Clip.antiAlias,
      child: (url == null || url.isEmpty)
          ? _initialsBox(context)
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _initialsBox(context),
            ),
    );
  }

  Widget _initialsBox(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: 0.18),
        borderRadius: AppRadii.rSmall,
      ),
      child: Text(
        _initials(name),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
