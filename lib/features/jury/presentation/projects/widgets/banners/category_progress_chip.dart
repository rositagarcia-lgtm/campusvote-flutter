// category_progress_chip.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/presentation/state/jury_state.dart'
    show CategoryRubricProgress;

/// Chip de progreso por categoría.
class CategoryProgressChip extends StatelessWidget {
  const CategoryProgressChip({
    super.key,
    required this.categoryName,
    required this.progress,
    required this.theme,
    required this.copy,
  });

  final String categoryName;
  final CategoryRubricProgress progress;
  final ThemeData theme;
  final SettingsCopy copy;

  @override
  Widget build(BuildContext context) {
    final isComplete = progress.allSubmitted;
    final ratio = progress.totalProjects > 0
        ? (progress.completedRubrics / progress.totalProjects).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: isComplete
            ? theme.colorScheme.tertiaryContainer
            : theme.colorScheme.secondaryContainer,
        borderRadius: AppRadii.rMedium,
        border: Border.all(
          color: isComplete
              ? theme.colorScheme.tertiary.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                categoryName,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isComplete
                      ? theme.colorScheme.onTertiaryContainer
                      : theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                isComplete
                    ? PhosphorIconsRegular.checkCircle
                    : PhosphorIconsRegular.clock,
                size: 14,
                color: isComplete
                    ? theme.colorScheme.onTertiaryContainer
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            copy.selectedCriteria(progress.completedRubrics, progress.totalProjects),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isComplete
                  ? theme.colorScheme.onTertiaryContainer
                  : theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (progress.totalProjects > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: AppRadii.rSmall,
              child: SizedBox(
                width: 120,
                height: 4,
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 4,
                  color: isComplete
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}