part of '../voting_ranking.dart';

class RankedProjectOption extends StatelessWidget {
  const RankedProjectOption({
    super.key,
    required this.project,
    required this.rank,
    required this.score,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final FairProjectModel project;
  final int? rank;
  final double? score;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration =
        AppMotion.reduced(context) ? Duration.zero : AppMotion.medium;
    final label = [
      if (rank != null) 'Puesto $rank',
      project.name,
      if (score != null)
        '${score!.toStringAsFixed(1)} de 20'
      else
        'Sin evaluar',
      selected ? 'Seleccionado' : 'No seleccionado',
    ].join('. ');

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.emphasized,
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: selected
                ? Color.alphaBlend(
                    scheme.primary.withValues(alpha: 0.08), scheme.surface)
                : scheme.surface,
            borderRadius: AppRadii.rLarge,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              _RankBadge(rank: rank),
              const SizedBox(width: AppSpacing.m),
              _Thumb(
                  url: project.coverUrl ?? project.logoUrl, name: project.name),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (project.categoryName != null)
                      Text(project.categoryName!,
                          style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.s),
                    _ScoreBar(score: score),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale:
                      CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  child: child,
                ),
                child: Icon(
                  selected
                      ? PhosphorIconsFill.checkCircle
                      : PhosphorIconsRegular.circle,
                  key: ValueKey(selected),
                  size: 26,
                  color: selected ? scheme.primary : scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int? rank;

  // Oro, plata y bronce para el podio; el resto en tono neutro.
  static const _podium = [
    Color(0xFFC9A227),
    Color(0xFF8E9AA6),
    Color(0xFFB0703C)
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final podium = rank != null && rank! <= 3;
    final color = podium ? _podium[rank! - 1] : scheme.onSurfaceVariant;
    return SizedBox(
      width: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (podium) Icon(PhosphorIconsFill.medal, size: 18, color: color),
          Text(
            rank == null ? '—' : '$rank°',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
