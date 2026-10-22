part of '../published_results_page.dart';

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.entry});

  final PodiumEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.m, AppSpacing.s, AppSpacing.m, 0),
      child: Row(
        children: [
          Icon(PhosphorIconsFill.medal,
              color: medalColor(entry.position), size: 22),
          const SizedBox(width: AppSpacing.s),
          Text('${entry.position}.°',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(entry.projectName, style: theme.textTheme.bodyMedium),
          ),
          if (entry.isMine)
            const StatusChip(label: 'Tu proyecto', tone: AppTone.success),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const pink = Color(0xFFE0457B);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: pink.withValues(alpha: 0.10),
        borderRadius: AppRadii.rLarge,
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsFill.heart, color: pink, size: 28),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FAVORITO DEL PÚBLICO',
                    style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800, letterSpacing: 1)),
                Text(name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                Text(
                    'El mejor calificado por los alumnos. No cambia el '
                    'resultado del jurado.',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
