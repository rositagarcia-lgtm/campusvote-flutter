part of '../student_project_detail_page.dart';

/// Una reseña o comentario (compañero o jurado) con su avatar y fecha.
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
