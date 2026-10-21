part of '../voting_body.dart';

Widget _buildVotingProjects(BuildContext context, ThemeData theme,
    VotingFormState state, VotingFormController controller) {
  if (state.visibleProjects.isEmpty) {
    return AppCard(
      child: Column(
        children: [
          Icon(PhosphorIconsRegular.archive, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.s),
          Text(
            'No hay proyectos disponibles',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'No encontramos proyectos aprobados para tu asignación. Puedes '
            'volver a consultar más tarde.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
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
          RankedProjectOption(
            project: project,
            rank: state.rankOf(project.id),
            score: state.scores[project.id],
            selected: state.selectedProjectId == project.id,
            enabled: state.canVote,
            onTap: () => controller.select(project.id),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
      ],
    ],
  );
}

/// Acción fija al pie. `canVote` ya incluye `!submitting`: el botón no se
/// rearma hasta que el POST termine.
