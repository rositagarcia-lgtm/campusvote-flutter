part of '../student_project_detail_page.dart';

class JuryReviewsPage extends ConsumerWidget {
  const JuryReviewsPage({super.key, required this.project});

  final StudentProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final feedback = ref.watch(projectFeedbackProvider(project));

    return Scaffold(
      appBar: AppBar(title: Text(text.t('Calificación del jurado'))),
      body: feedback.when(
        loading: () => const AppLoader(),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Text(
              text.t(
                  'No pudimos cargar la valoración. Desliza para reintentar.'),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        data: (data) {
          if (!data.published) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Text(
                  text.t(
                      'La calificación por estrellas y el voto aparecerán cuando se publiquen los resultados.'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            );
          }
          final average = data.average;
          final reviews = data.reviews;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    average == null ? '—' : average.toStringAsFixed(1),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (average != null)
                          _StarRow(
                            rating: average.round().clamp(1, 5).toInt(),
                            label: '',
                          ),
                        Text(
                          text.t(reviews.length == 1
                              ? '1 reseña del jurado'
                              : '${reviews.length} reseñas del jurado'),
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${text.t('Votos del jurado')} · ${text.votes(data.votes ?? 0)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              for (var star = 5; star >= 1; star--)
                _RatingBar(
                  star: star,
                  count:
                      reviews.where((review) => review.rating == star).length,
                  total: reviews.length,
                ),
              const SizedBox(height: AppSpacing.l),
              Text(
                text.t('Reseñas del jurado'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.m),
                  child: Text(
                    text.t('Aún no hay calificaciones por estrellas.'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              for (final review in reviews) _ReviewBlock(review: review),
            ],
          );
        },
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({
    required this.star,
    required this.count,
    required this.total,
  });

  final int star;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
              width: 12,
              child: Text('$star', style: theme.textTheme.labelMedium)),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                color: theme.colorScheme.primary,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewBlock extends StatelessWidget {
  const _ReviewBlock({required this.review});

  final ProjectReview review;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final comment = review.comment;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StarRow(
            rating: review.rating,
            label: text.ratingOutOfFive(review.rating),
          ),
          if (comment != null) ...[
            const SizedBox(height: AppSpacing.xs),
            TranslatableText(comment, style: theme.textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}
