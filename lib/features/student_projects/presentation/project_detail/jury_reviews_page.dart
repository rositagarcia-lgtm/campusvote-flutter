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
      for (final note in juryData.comments)
        _Voice(who: 'Jurado', comment: note.comment, date: note.createdAt),
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
      juryVotes: juryData.votes,
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
