import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';

/// Casilla de un criterio de la rúbrica.
///
/// El backend es un CHECKLIST (`checked` booleano), no un slider: por eso el
/// control es un interruptor y no un control numérico.
class RubricCriterionTile extends StatelessWidget {
  const RubricCriterionTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
    this.enabled = true,
    this.position,
  });

  final String title;
  final String? description;
  final bool value;
  final int? position;

  /// `false` cuando la hoja ya se finalizó: el backend responde 409.
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Material(
        color: value ? context.brandPrimarySoft : theme.colorScheme.surface,
        borderRadius: AppRadii.rMedium,
        child: InkWell(
          borderRadius: AppRadii.rMedium,
          onTap: enabled ? () => onChanged(!value) : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: value,
                  onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.rSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position != null ? '$position. $title' : title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (description != null && description!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(description!, style: theme.textTheme.bodySmall),
                      ],
                    ],
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
