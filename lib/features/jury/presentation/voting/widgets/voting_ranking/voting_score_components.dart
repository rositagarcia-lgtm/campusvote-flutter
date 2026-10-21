part of '../voting_ranking.dart';

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final resolved = AppEnv.mediaUrl(url);
    final fallback = DecoratedBox(
      decoration: BoxDecoration(gradient: context.brandGradient),
      child: Center(
        child: Text(
          name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
          style: const TextStyle(
              color: AppColors.inkInverse, fontWeight: FontWeight.w800),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: AppRadii.rMedium,
      child: SizedBox(
        width: 52,
        height: 52,
        child: resolved == null
            ? fallback
            : Image.network(resolved,
                fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback),
      ),
    );
  }
}

/// Barra del puntaje propio (sobre 20) que se llena al aparecer.
class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.score});

  final double? score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (score == null) {
      return Text(
        'Sin evaluar',
        style: theme.textTheme.labelSmall
            ?.copyWith(color: scheme.onSurfaceVariant),
      );
    }
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: (score! / 20).clamp(0, 1)),
              duration:
                  AppMotion.reduced(context) ? Duration.zero : AppMotion.slow,
              curve: AppMotion.emphasized,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 6,
                color: scheme.primary,
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Text(
          '${score!.toStringAsFixed(1)}/20',
          style: theme.textTheme.labelMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
