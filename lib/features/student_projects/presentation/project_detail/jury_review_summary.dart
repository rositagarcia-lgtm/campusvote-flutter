part of '../student_project_detail_page.dart';

/// Promedio, estrellas e histograma de las reseñas del proyecto.
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
