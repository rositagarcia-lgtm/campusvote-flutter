// fair_progress_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/core/widgets/app_palette.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/presentation/state/jury_state.dart'
    show CategoryRubricProgress;
import 'package:campusvote_flutter/features/jury/presentation/providers/fairs/jury_fair_providers.dart'
    show categoryRubricProgressProvider;
import 'category_progress_chip.dart';
import 'progress_banner_skeleton.dart';

/// Avance de la evaluación en la feria por categoría.
///
/// Muestra el progreso de rúbricas finalizadas por categoría,
/// indicando cuáles están completas y cuáles tienen pendientes.
class FairProgressBanner extends ConsumerWidget {
  const FairProgressBanner({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(categoryRubricProgressProvider(fairId));
    final theme = Theme.of(context);
    final copy = SettingsCopy.of(context);

    return progressAsync.when(
      loading: () => const ProgressBannerSkeleton(),
      error: (_, __) => const ProgressBannerError(),
      data: (categoryProgress) => ProgressBannerContent(
        copy: copy,
        theme: theme,
        categoryProgress: categoryProgress,
      ),
    );
  }
}

class ProgressBannerError extends StatelessWidget {
  const ProgressBannerError();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = SettingsCopy.of(context);
    return Text(
      copy.t('No se pudo cargar el progreso de evaluaciones'),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.error,
      ),
    );
  }
}

class ProgressBannerContent extends StatelessWidget {
  const ProgressBannerContent({
    required this.copy,
    required this.theme,
    required this.categoryProgress,
  });

  final SettingsCopy copy;
  final ThemeData theme;
  final Map<String, CategoryRubricProgress> categoryProgress;

  @override
  Widget build(BuildContext context) {
    final muted = appMuted(theme.brightness == Brightness.dark);

    if (categoryProgress.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calcular totales globales
    final totalProjects = categoryProgress.values
        .fold<int>(0, (sum, p) => sum + p.totalProjects);
    final totalCompleted = categoryProgress.values
        .fold<int>(0, (sum, p) => sum + p.completedRubrics);
    final totalPending = categoryProgress.values
        .fold<int>(0, (sum, p) => sum + p.pendingCount);
    final globalRatio = totalProjects > 0
        ? (totalCompleted / totalProjects).clamp(0.0, 1.0)
        : 0.0;
    final allComplete = totalProjects > 0 && totalCompleted == totalProjects;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                copy.t('Tu progreso de evaluación'),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              copy.selectedCriteria(totalCompleted, totalProjects),
              style: theme.textTheme.labelLarge?.copyWith(
                color: muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        ClipRRect(
          borderRadius: AppRadii.rSmall,
          child: LinearProgressIndicator(
            value: globalRatio,
            minHeight: 6,
            color: allComplete
                ? theme.colorScheme.tertiary
                : theme.colorScheme.primary,
            backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.12),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        // Leyenda por categoría
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (final entry in categoryProgress.entries)
              CategoryProgressChip(
                categoryName: entry.key == 'default' ? copy.t('General') : entry.key,
                progress: entry.value,
                theme: theme,
                copy: copy,
              ),
          ],
        ),
        if (totalPending > 0) ...[
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.info,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  copy.t(
                    'Debes completar $totalPending rúbrica(s) pendiente(s) para habilitar la votación oficial.',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}