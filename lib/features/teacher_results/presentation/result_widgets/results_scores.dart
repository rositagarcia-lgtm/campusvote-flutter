part of '../teacher_results_widgets.dart';

class ScoreBarRow extends StatelessWidget {
  const ScoreBarRow({
    super.key,
    required this.label,
    required this.average,
    this.caption,
  });

  final String label;
  final String? caption;
  final double average;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      label: '$label: ${_score(average)} de 5',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Text(_score(average),
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            if (caption != null)
              Text(caption!, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (average / 5).clamp(0, 1)),
                duration:
                    AppMotion.reduced(context) ? Duration.zero : AppMotion.slow,
                curve: AppMotion.emphasized,
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  color: scheme.primary,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuántos puntajes recibió de cada estrella.
class DistributionBars extends StatelessWidget {
  const DistributionBars({super.key, required this.distribution});

  final Map<int, int> distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = distribution.values.fold<int>(0, (a, b) => a + b);
    return Column(
      children: [
        for (final stars in [5, 4, 3, 2, 1])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text('$stars ★', style: theme.textTheme.labelMedium),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value:
                          total == 0 ? 0 : (distribution[stars] ?? 0) / total,
                      minHeight: 8,
                      color: scheme.primary,
                      backgroundColor: scheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${distribution[stars] ?? 0}',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Comentario anónimo de un alumno.
class AnonymousComment extends StatelessWidget {
  const AnonymousComment({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: _cardDecoration(theme.colorScheme),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIconsFill.quotes,
              size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
