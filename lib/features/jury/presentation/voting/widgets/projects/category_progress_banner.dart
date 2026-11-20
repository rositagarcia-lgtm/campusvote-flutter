// category_progress_banner.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/core/widgets/app_card.dart';
import 'package:campusvote_flutter/core/widgets/app_status_chip.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/presentation/state/jury_state.dart'
    show CategoryRubricProgress;

/// Banner de progreso de rúbricas para la categoría activa.
class CategoryProgressBanner extends StatelessWidget {
  const CategoryProgressBanner({
    super.key,
    required this.progress,
    required this.categoryName,
  });

  final CategoryRubricProgress progress;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = SettingsCopy.of(context);
    final ratio = progress.totalProjects > 0
        ? (progress.completedRubrics / progress.totalProjects).clamp(0.0, 1.0)
        : 0.0;
    final isComplete = progress.allSubmitted;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.t('Evaluaciones de $categoryName'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      copy.selectedCriteria(
                          progress.completedRubrics, progress.totalProjects),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: isComplete
                    ? copy.t('Completo')
                    : copy.t('${progress.pendingCount} pendiente(s)'),
                tone: isComplete ? AppTone.success : AppTone.warning,
                icon: isComplete
                    ? PhosphorIconsRegular.checkCircle
                    : PhosphorIconsRegular.clock,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          ClipRRect(
            borderRadius: AppRadii.rSmall,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              color: isComplete
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          if (!isComplete && progress.pendingRubricProjectIds.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              copy.t(
                'Debes completar todas las rúbricas para habilitar la votación oficial.',
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}