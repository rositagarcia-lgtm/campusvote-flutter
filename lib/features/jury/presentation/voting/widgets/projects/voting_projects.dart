// voting_projects.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/widgets/app_card.dart';
import 'package:campusvote_flutter/core/widgets/app_motion.dart'
    show AppMotion;
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/presentation/state/jury_state.dart'
    show VotingFormState;
import 'package:campusvote_flutter/features/jury/presentation/providers/forms/voting/voting_controller.dart'
    show VotingFormController;
import 'package:campusvote_flutter/core/theme/app_dimensions.dart'
    show AppSpacing;
import 'voting_project_tile.dart';
import 'category_progress_banner.dart';
import '../voting_ranking/voting_ranking_header.dart';

/// Construye la lista de proyectos votables con banner de progreso.
Widget buildVotingProjects(BuildContext context, ThemeData theme,
    VotingFormState state, VotingFormController controller) {
  final copy = SettingsCopy.of(context);

  // Mostrar banner de progreso de rúbricas por categoría
  final progress = state.activeCategoryProgress;
  final showProgressBanner = progress != null && progress.totalProjects > 0;

  if (state.visibleProjects.isEmpty) {
    return AppCard(
      child: Column(
        children: [
          Icon(PhosphorIconsRegular.archive, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.s),
          Text(
            copy.t('No hay proyectos disponibles'),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            copy.t(
              'No encontramos proyectos aprobados para tu asignación. Puedes volver a consultar más tarde.',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (showProgressBanner) ...[
        CategoryProgressBanner(
          progress: progress,
          categoryName: state.activeCategory?.name ?? copy.t('Tu categoría'),
        ),
        const SizedBox(height: AppSpacing.m),
      ],
      VotingRankingHeader(
        scored: state.visibleProjects
            .where((p) => state.scores.containsKey(p.id))
            .length,
        total: state.visibleProjects.length,
      ),
      const SizedBox(height: AppSpacing.m),
      for (final (i, project) in state.rankedProjects.indexed) ...[
        AppMotion.reveal(
          i + 1,
          VotingProjectTile(
            project: project,
            rank: state.rankOf(project.id),
            score: state.scores[project.id],
            selected: state.selectedProjectId == project.id,
            enabled: state.canVote,
            hasCompletedRubric: state.scores.containsKey(project.id),
            onTap: () => controller.select(project.id),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
      ],
    ],
  );
}