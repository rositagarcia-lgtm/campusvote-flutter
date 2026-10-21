part of '../published_results_page.dart';

class _WinnerTile extends StatelessWidget {
  const _WinnerTile({required this.entry});

  final PodiumEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.12),
        borderRadius: AppRadii.rMedium,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadii.rMedium,
            child: SizedBox(
              width: 64,
              height: 64,
              child: entry.coverUrl == null
                  ? const ColoredBox(
                      color: _gold,
                      child: Icon(PhosphorIconsFill.trophy,
                          color: Colors.white, size: 32),
                    )
                  : Image.network(entry.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                            color: _gold,
                            child: Icon(PhosphorIconsFill.trophy,
                                color: Colors.white, size: 32),
                          )),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(PhosphorIconsFill.trophy, color: _gold, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Text('GANADOR',
                      style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800, letterSpacing: 1)),
                ]),
                Text(entry.projectName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                if (entry.isMine) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const StatusChip(label: 'Tu proyecto', tone: AppTone.success),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
