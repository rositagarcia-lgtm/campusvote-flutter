import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'app_palette.dart';

/// Dato de una métrica mostrada en [StatsStrip].
class StatItem {
  const StatItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  /// Etiqueta en tono secundario (por ejemplo "Asignadas").
  final String label;

  /// Valor numérico de la métrica.
  final int value;

  /// Resalta el valor con el color primario.
  final bool highlight;
}

/// Tarjeta plana con la métrica en serif y la etiqueta en tono secundario.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.item});

  final StatItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: '${item.label}: ${item.value}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadii.rLarge,
          border: Border.all(color: appBorder(isDark)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${item.value}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'serif',
                fontWeight: FontWeight.w700,
                color: item.highlight ? theme.colorScheme.primary : null,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Flexible(
              child: Text(
                item.label,
                maxLines: 2,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: appMuted(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de métricas: tarjetas planas separadas por [AppSpacing.m].
class StatsStrip extends StatelessWidget {
  const StatsStrip({super.key, required this.items});

  final List<StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.m),
          Expanded(child: StatTile(item: items[i])),
        ],
      ],
    );
  }
}
