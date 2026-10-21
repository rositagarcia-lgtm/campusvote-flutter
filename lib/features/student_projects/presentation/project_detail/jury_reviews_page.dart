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
    final classmates = peerData != null &&
            (peerData.available || peerData.reviews.isNotEmpty)
        ? peerData
        : null;
    final voices = <_Voice>[
      if (classmates != null)
        for (final review in classmates.reviews)
          if (review.comment != null || review.score != null)
            _Voice(
              who: review.author ?? 'Compañero',
              rating: review.score,
              comment: review.comment,
              date: review.createdAt,
              avatarUrl: review.avatarUrl,
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

    if (voices.isEmpty && !(project.fair?.reviewsOpen ?? false) && !juryData.published) {
      return _ReviewsMessage(
        icon: PhosphorIconsRegular.star,
        title: text.t('Reseñas no disponibles'),
        message: text.t(
          'Las de tus compañeros y las del jurado se ven en cuanto se envían, durante la feria y 7 días después del cierre.',
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
  const _Voice({
    required this.who,
    this.rating,
    this.comment,
    this.date,
    this.avatarUrl,
  });

  final String who;
  final int? rating;
  final String? comment;
  final DateTime? date;
  final String? avatarUrl;
}

class _ReviewsBody extends StatelessWidget {
  const _ReviewsBody({
    required this.voices,
    this.juryVotes,
  });

  final List<_Voice> voices;
  final int? juryVotes;

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
    final countLabel = voices.length == 1
        ? text.t('1 reseña')
        : '${voices.length} ${text.t('reseñas')}';
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.xxl,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 112,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    average == null ? '—' : average.toStringAsFixed(1),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _Stars(rating: average ?? 0, size: 16),
                  const SizedBox(height: AppSpacing.xs),
                  Text('($countLabel)', style: muted),
                  if (juryVotes != null)
                    Text(
                      '${text.t('Votos del jurado')} · ${text.votes(juryVotes!)}',
                      style: muted,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                children: [
                  for (var star = 5; star >= 1; star--)
                    _HistogramRow(
                      star: star,
                      count: rated.where((rating) => rating == star).length,
                      total: rated.length,
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
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
    final scheme = theme.colorScheme;
    final jury = voice.who == 'Jurado';
    final named = !jury && voice.who != 'Compañero';
    final label = named ? voice.who : text.t(voice.who);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReviewAvatar(voice: voice, label: label, jury: jury),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (date != null)
                        Text(
                          _reviewDate(date.toLocal()),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  if (voice.rating != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _Stars(rating: voice.rating!.toDouble(), size: 16),
                  ],
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    comment ?? text.t('Calificación sin comentario'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.4,
                      color: comment == null ? scheme.onSurfaceVariant : null,
                    ),
                  ),
                ],
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

const _reviewMonths = [
  'ene.', 'feb.', 'mar.', 'abr.', 'may.', 'jun.',
  'jul.', 'ago.', 'sep.', 'oct.', 'nov.', 'dic.',
];

String _reviewDate(DateTime date) =>
    '${date.day} ${_reviewMonths[date.month - 1]} ${date.year}';

class _ReviewAvatar extends StatelessWidget {
  const _ReviewAvatar({
    required this.voice,
    required this.label,
    required this.jury,
  });

  final _Voice voice;
  final String label;
  final bool jury;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = AppEnv.mediaUrl(voice.avatarUrl);
    if (url != null) {
      return ClipOval(
        child: Image.network(
          url,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(context, scheme),
        ),
      );
    }
    return _fallback(context, scheme);
  }

  Widget _fallback(BuildContext context, ColorScheme scheme) {
    if (jury || voice.who == 'Compañero') {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(
          jury ? PhosphorIconsFill.star : PhosphorIconsRegular.userCircle,
          size: 20,
          color: scheme.primary,
        ),
      );
    }
    final initial = label.isEmpty ? '?' : label[0].toUpperCase();
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
