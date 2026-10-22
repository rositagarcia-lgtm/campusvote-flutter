part of '../published_results_page.dart';

/// Estado de espera mientras la feria no publica sus resultados.
class _PendingResults extends StatelessWidget {
  const _PendingResults({required this.results});

  final PublishedResults results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final date = results.fair.publishedAt?.toLocal();
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.4,
    );
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Row(
            children: [
              AppIconTile(
                icon: PhosphorIconsRegular.calendarDots,
                color: scheme.primary,
                extent: 52,
                iconSize: 26,
                radius: AppRadii.rLarge,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      results.fair.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (date != null) ...[
                      const SizedBox(height: AppSpacing.s),
                      Row(
                        children: [
                          Icon(PhosphorIconsRegular.calendarDots,
                              size: 14, color: scheme.onSurfaceVariant),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'Resultados oficiales · ${_dmy(date)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(PhosphorIconsRegular.info, color: scheme.primary),
              Container(
                width: 2,
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                color: scheme.primary.withValues(alpha: 0.7),
              ),
              Expanded(
                child: Text(
                  'Gana el proyecto más votado por el jurado de cada '
                  'categoría; un empate lo decide el puntaje de la rúbrica. '
                  'Los votos son secretos.',
                  style: muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _PendingArt(),
        const SizedBox(height: AppSpacing.l),
        Text(
          'Los resultados aún no están',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'disponibles',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          'Estamos en proceso de evaluación de los proyectos. '
          'Los resultados se publicarán aquí una vez que el '
          'jurado haya finalizado su revisión.',
          textAlign: TextAlign.center,
          style: muted,
        ),
      ],
    );
  }
}

String _dmy(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

class _PendingArt extends StatelessWidget {
  const _PendingArt();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 168,
            height: 78,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(80),
            ),
          ),
          Icon(PhosphorIconsFill.trophy, size: 88, color: primary),
          Positioned(
            right: 86,
            bottom: 22,
            child: Icon(PhosphorIconsRegular.clock, size: 34, color: primary),
          ),
          Positioned(
            left: 96,
            top: 18,
            child: Icon(PhosphorIconsFill.star, size: 14, color: primary),
          ),
        ],
      ),
    );
  }
}
