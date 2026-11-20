// voting_project_tile.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart'
    show AppRadii, AppSpacing;
import 'package:campusvote_flutter/core/widgets/app_motion.dart'
    show AppMotion;
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart'
    show FairProjectModel;
import '_rubric_pending_chip.dart';
import '_rank_badge.dart';
import '_thumb.dart';
import '_score_bar.dart';

/// Tile de proyecto en la lista de votación con indicador de rúbrica completada.
class VotingProjectTile extends StatelessWidget {
  const VotingProjectTile({
    super.key,
    required this.project,
    required this.rank,
    required this.score,
    required this.selected,
    required this.enabled,
    required this.hasCompletedRubric,
    required this.onTap,
  });

  final FairProjectModel project;
  final int? rank;
  final double? score;
  final bool selected;
  final bool enabled;
  final bool hasCompletedRubric;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration =
        AppMotion.reduced(context) ? Duration.zero : AppMotion.medium;
    final copy = SettingsCopy.of(context);
    final canSelect = enabled && hasCompletedRubric;

    final label = [
      if (rank != null) copy.rank(rank, false),
      project.name,
      if (score != null)
        copy.isEnglish
            ? '${score!.toStringAsFixed(1)} out of 20'
            : '${score!.toStringAsFixed(1)} de 20'
      else if (hasCompletedRubric)
        copy.t('Evaluado')
      else
        copy.t('Rúbrica pendiente'),
      copy.t(selected ? 'Seleccionado' : 'No seleccionado'),
    ].join('. ');

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      enabled: canSelect,
      onTap: canSelect ? onTap : null,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: canSelect ? onTap : null,
        borderRadius: AppRadii.rLarge,
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.emphasized,
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: selected
                ? Color.alphaBlend(
                    scheme.primary.withValues(alpha: 0.08), scheme.surface)
                : scheme.surface,
            borderRadius: AppRadii.rLarge,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              RankBadge(rank: rank),
              const SizedBox(width: AppSpacing.m),
              ProjectThumb(
                  url: project.coverUrl ?? project.logoUrl, name: project.name),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (!hasCompletedRubric) ...[
                          const SizedBox(width: AppSpacing.s),
                          const RubricPendingChip(),
                        ],
                      ],
                    ),
                    if (project.categoryName != null)
                      Text(project.categoryName!,
                          style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.s),
                    ScoreBar(score: score, hasCompletedRubric: hasCompletedRubric),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale:
                      CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  child: child,
                ),
                child: Icon(
                  selected
                      ? PhosphorIconsFill.checkCircle
                      : PhosphorIconsRegular.circle,
                  key: ValueKey(selected),
                  size: 26,
                  color: selected ? scheme.primary : scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}