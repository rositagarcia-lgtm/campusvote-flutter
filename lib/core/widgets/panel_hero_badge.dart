import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

/// Identidad de la organización dentro del encabezado de panel.
class PanelHeroOrgBadge extends StatelessWidget {
  final String? logoUrl;
  final String name;
  final Color onPrimary;

  const PanelHeroOrgBadge({
    super.key,
    required this.logoUrl,
    required this.name,
    required this.onPrimary,
  });

  static String _initials(String value) {
    final words =
        value.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.touchTarget - AppSpacing.m,
      height: AppDimensions.touchTarget - AppSpacing.m,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.rSmall,
      ),
      clipBehavior: Clip.antiAlias,
      child: (logoUrl == null || logoUrl!.isEmpty)
          ? _initialsBox(context)
          : Image.network(
              logoUrl!,
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
