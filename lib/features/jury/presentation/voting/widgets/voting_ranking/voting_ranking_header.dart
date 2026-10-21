part of '../voting_ranking.dart';

/// Encabezado de la votación.
///
/// La barra superior ya muestra logo, organización y "Votación oficial"; aquí
/// solo va lo que falta: qué feria se vota, la regla del voto y el tiempo.
class VotingHero extends StatelessWidget {
  const VotingHero({super.key, required this.fairName, required this.status});

  final String? fairName;
  final VotingStatusModel status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fairName ?? 'Votación de la feria',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            Icon(PhosphorIconsRegular.lockSimple,
                size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs + 2),
            Expanded(
              child: Text(
                'Un voto por jurado · anónimo · no se puede cambiar',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        if (status.endsAt != null || status.startsAt != null) ...[
          const SizedBox(height: AppSpacing.m),
          VotingCountdown(endsAt: status.endsAt, startsAt: status.startsAt),
        ],
      ],
    );
  }
}

/// Explica el orden: es el propio criterio del jurado, no el ranking oficial.
class VotingRankingHeader extends StatelessWidget {
  const VotingRankingHeader(
      {super.key, required this.scored, required this.total});

  final int scored;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(PhosphorIconsRegular.trendUp, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu ranking por rúbrica',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                scored == 0
                    ? 'Aún no finalizas rúbricas en esta feria. Puedes votar igual.'
                    : 'Ordenado de mayor a menor según las $scored de $total rúbricas '
                        'que finalizaste. Solo tú lo ves.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de proyecto votable con posición, portada y puntaje propio.
