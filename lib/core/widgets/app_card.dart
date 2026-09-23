import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool bordered;
  final bool elevated;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.bordered = true,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = color ?? theme.colorScheme.surface;
    final border = bordered
        ? Border.all(
            color: isDark
                ? const Color(0xFF29403D)
                : const Color(0xFFE2E8F0),
          )
        : null;

    final card = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.rLarge,
        border: border,
        boxShadow: elevated ? AppShadows.card : AppShadows.none,
      ),
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.l,
          ),
      child: child,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.rLarge,
        child: card,
      ),
    );
  }
}