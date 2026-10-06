import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'app_palette.dart';

/// Número destacado del resumen del panel (etapas completadas, total, etc.).
class PanelOverviewNumber extends StatelessWidget {
  const PanelOverviewNumber({super.key, 
    required this.value,
    required this.label,
    required this.color,
    this.compact = false,
  });

  final int value;
  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = appMuted(theme.brightness == Brightness.dark);
    final displayLabel = value == 1 && label.endsWith('s')
        ? label.substring(0, label.length - 1)
        : label;
    return Semantics(
      label: '$value $displayLabel',
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.xs : AppSpacing.m,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              displayLabel,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
