part of '../student_project_detail_page.dart';

/// Resumen visible en la ficha de tu proyecto: promedio de estrellas, cuántas
/// reseñas y comentarios dejaron el jurado y tus compañeros, y acceso al detalle.
class _ReviewsSummaryCard extends ConsumerWidget {
  const _ReviewsSummaryCard({required this.project, required this.onOpen});

  final StudentProject project;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.4,
    );
    if (!project.hasFeedback) {
      return Text(
        text.t(
          'Las reseñas del jurado y de tus compañeros se ven en cuanto se envían, durante la feria y 7 días después del cierre.',
        ),
        style: muted,
      );
    }

    final jury = ref.watch(projectFeedbackProvider(project));
    final fair = project.fair;
    final peers = fair == null
        ? null
        : ref.watch(
            peerFeedbackProvider((fairId: fair.id, projectId: project.id)));
    if (jury.isLoading || (peers?.isLoading ?? false)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final juryData = jury.valueOrNull ?? const ProjectFeedback.hidden();
    final peerReviews = peers?.valueOrNull?.reviews ?? const [];
    final ratings = [
      for (final review in juryData.reviews) review.rating,
      for (final review in peerReviews)
        if (review.score != null) review.score!,
    ];
    final average = ratings.isEmpty
        ? null
        : ratings.fold<int>(0, (sum, r) => sum + r) / ratings.length;
    final juryCount = juryData.reviews.length + juryData.comments.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              average == null ? '—' : average.toStringAsFixed(1),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Stars(rating: average ?? 0, size: 18),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${text.t('Jurado')}: $juryCount', style: muted),
                  Text('${text.t('Compañeros')}: ${peerReviews.length}',
                      style: muted),
                ],
              ),
            ),
          ],
        ),
        if (juryData.votes != null) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            '${text.t('Votos del jurado')} · ${text.votes(juryData.votes!)}',
            style: muted,
          ),
        ],
        const SizedBox(height: AppSpacing.m),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: onOpen,
            icon: const Icon(PhosphorIconsRegular.chatCircle),
            label: Text(text.t('Ver reseñas y comentarios')),
          ),
        ),
      ],
    );
  }
}
