// _score_bar.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart'
    show AppRadii, AppSpacing;
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';

/// Barra de puntuación del proyecto en la lista de votación.
class ScoreBar extends StatelessWidget {
  const ScoreBar({
    super.key,
    required this.score,
    required this.hasCompletedRubric,
  });

  final double? score;
  final bool hasCompletedRubric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = SettingsCopy.of(context);

    if (!hasCompletedRubric) {
      return Row(
        children: [
          Icon(PhosphorIconsRegular.clock, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(
            copy.t('Rúbrica pendiente'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (score == null) {
      return Text(
        copy.t('Evaluado'),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final value = (score! / 20).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: AppRadii.rSmall,
            child: LinearProgressIndicator(
              value: value,
              minHeight: 4,
              color: theme.colorScheme.tertiary,
              backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.15),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Text(
          copy.isEnglish
              ? '${score!.toStringAsFixed(1)} out of 20'
              : '${score!.toStringAsFixed(1)} de 20',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}