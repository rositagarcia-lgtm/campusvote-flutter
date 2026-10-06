// notification_filter_bar.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../notification_item.dart';
import '../notification_filters.dart';

/// Barra de filtros de la bandeja: una píldora por familia de avisos.
///
/// Muestra el nombre y el contador de cada filtro en la misma línea. Desplaza
/// en horizontal para que los tres quepan también en 320 px sin partirse.
class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    super.key,
    required this.selected,
    required this.items,
    required this.onSelected,
  });

  final NotificationFilter selected;
  final List<NotificationItem> items;
  final ValueChanged<NotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final counts = notificationFilterCounts(items);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final filter in NotificationFilter.values) ...[
            if (filter != NotificationFilter.values.first)
              const SizedBox(width: AppSpacing.s),
            _FilterPill(
              label: filter.label,
              count: counts[filter] ?? 0,
              selected: selected == filter,
              onTap: () => onSelected(filter),
            ),
          ],
        ],
      ),
    );
  }
}

/// Píldora de filtro con su contador.
///
/// El estado se marca con relleno del primario y un punto, no solo con el color
/// del texto, y la zona táctil no baja de 44 px aunque la píldora sea baja.
class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Semantics(
      button: true,
      selected: selected,
      label: '$label, $count',
      excludeSemantics: true,
      child: Material(
        color: selected ? primary : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLarge,
          side: BorderSide(
            color: selected ? primary : appBorder(isDark),
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: AppDimensions.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Container(
                      width: AppSpacing.s,
                      height: AppSpacing.s,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                  ],
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected ? theme.colorScheme.onPrimary : null,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  // Contador en su propia píldora: se lee de un vistazo, sin
                  // ir pegado al nombre del filtro.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.onPrimary.withValues(alpha: 0.24)
                          : primary.withValues(alpha: isDark ? 0.20 : 0.10),
                      borderRadius: AppRadii.rSmall,
                    ),
                    child: Text(
                      '$count',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: selected ? theme.colorScheme.onPrimary : primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}