part of '../student_project_detail_page.dart';

const _starGold = Color(0xFFE6A100);

class JuryReviewsPage extends ConsumerWidget {
  const JuryReviewsPage({super.key, required this.project});

  final StudentProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = SettingsCopy.of(context);
    final jury = ref.watch(projectFeedbackProvider(project));
    final fair = project.fair;
    final peers = fair == null
        ? null
        : ref.watch(peerFeedbackProvider((fairId: fair.id, projectId: project.id)));

    return Scaffold(
      appBar: AppBar(title: Text(text.t('Reseñas'))),
      body: _reviewsBody(context, text, jury, peers),
    );
  }

  Widget _reviewsBody(
    BuildContext context,
    SettingsCopy text,
    AsyncValue<ProjectFeedback> jury,
    AsyncValue<PeerFeedback>? peers,
  ) {
    if (jury.isLoading || (peers?.isLoading ?? false)) return const AppLoader();
    if (jury.hasError && (peers == null || peers.hasError)) {
      return _ReviewsMessage(
        icon: PhosphorIconsRegular.warningCircle,
        title: text.t('No pudimos cargar la valoración'),
        message: text.t('Desliza el proyecto e inténtalo de nuevo.'),
      );
    }

    final juryData = jury.valueOrNull ?? const ProjectFeedback.hidden();
    final peerData = peers?.valueOrNull;
    final open = project.fair?.reviewsOpen ?? false;
    final classmates = open && (peerData?.available ?? false) ? peerData : null;
    final showClassmateScores =
        classmates != null && classmates.votes >= classmates.minVotes;
    final voices = <_Voice>[
      if (classmates != null)
        for (final review in classmates.reviews)
          if (review.comment != null || review.score != null)
            _Voice(
              who: 'Compañero',
              rating: showClassmateScores ? review.score : null,
              comment: review.comment,
            ),
      if (juryData.published)
        for (final review in juryData.reviews)
          _Voice(
            who: 'Jurado',
            rating: review.rating,
            comment: review.comment,
            date: review.createdAt,
          ),
    ];

    if (voices.isEmpty && !open && !juryData.published) {
      return _ReviewsMessage(
        icon: PhosphorIconsRegular.star,
        title: text.t('Reseñas no disponibles'),
        message: text.t(
          'Las de tus compañeros se ven durante la feria y 7 días después del cierre. Las del jurado, desde que se publican los resultados.',
        ),
      );
    }
    if (voices.isEmpty) {
      return _ReviewsMessage(
        icon: PhosphorIconsRegular.star,
        title: text.t('No hay reseñas ni calificaciones'),
        message: text.t(
          'Cuando tus compañeros o el jurado califiquen este proyecto, el promedio y las reseñas se verán aquí.',
        ),
      );
    }
    return _ReviewsBody(
      voices: voices,
      juryVotes: juryData.published ? juryData.votes : null,
      juryPending: !juryData.published,
    );
  }
}

class _ReviewsMessage extends StatelessWidget {
  const _ReviewsMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: scheme.primary),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Voice {
  const _Voice({required this.who, this.rating, this.comment, this.date});

  final String who;
  final int? rating;
  final String? comment;
  final DateTime? date;
}

class _ReviewsBody extends StatelessWidget {
  const _ReviewsBody({
    required this.voices,
    required this.juryPending,
    this.juryVotes,
  });

  final List<_Voice> voices;
  final int? juryVotes;
  final bool juryPending;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final rated = [
      for (final voice in voices)
        if (voice.rating != null) voice.rating!,
    ];
    final average = rated.isEmpty
        ? null
        : rated.fold<int>(0, (sum, rating) => sum + rating) / rated.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.xxl,
      ),
      children: [
        if (average != null)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  average.toStringAsFixed(1),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Stars(rating: average, size: 22),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        voices.length == 1
                            ? text.t('1 reseña')
                            : '${voices.length} ${text.t('reseñas')}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (juryVotes != null)
                        Text(
                          '${text.t('Votos del jurado')} · ${text.votes(juryVotes!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (average != null) const SizedBox(height: AppSpacing.l),
        if (rated.isNotEmpty)
          for (var star = 5; star >= 1; star--)
            _HistogramRow(
              star: star,
              count: rated.where((rating) => rating == star).length,
              total: rated.length,
            ),
        if (juryPending) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            text.t('Las del jurado se ven al publicar los resultados.'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.l),
        Text(
          text.t('Reseñas'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        for (final voice in voices) _ReviewCard(voice: voice),
      ],
    );
  }
}

class _HistogramRow extends StatelessWidget {
  const _HistogramRow({
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
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: Text('$star', style: theme.textTheme.labelLarge),
          ),
          const Icon(PhosphorIconsFill.star, size: 14, color: _starGold),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 10,
                color: _starGold,
                backgroundColor: _starGold.withValues(alpha: 0.16),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          SizedBox(
            width: 40,
            child: Text(
              total == 0 ? '0%' : '${((count / total) * 100).round()}%',
              textAlign: TextAlign.end,
              style: theme.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.voice});

  final _Voice voice;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final date = voice.date;
    final comment = voice.comment;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (voice.rating != null)
                  _Stars(rating: voice.rating!.toDouble(), size: 16)
                else
                  Text(
                    text.t('Compañero'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                const Spacer(),
                if (date != null)
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            if (voice.rating != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                text.t(voice.who),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              comment ?? text.t('Calificación sin comentario'),
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.4,
                color: comment == null
                    ? theme.colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, required this.size});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final empty = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            star <= rating.round()
                ? PhosphorIconsFill.star
                : PhosphorIconsRegular.star,
            size: size,
            color: star <= rating.round() ? _starGold : empty,
          ),
      ],
    );
  }
}
