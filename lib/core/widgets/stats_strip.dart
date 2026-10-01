import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'app_card.dart';

/// Franja responsive para mostrar métricas resumidas.
class StatsStrip extends StatelessWidget {
  final List<({String label, String value, IconData? icon})> stats;

  const StatsStrip({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const VerticalDivider(width: AppSpacing.l),
            Expanded(
              child: Column(
                children: [
                  if (stats[i].icon != null)
                    Icon(
                      stats[i].icon,
                      size: AppDimensions.iconMedium,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  Text(
                    stats[i].value,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    stats[i].label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
