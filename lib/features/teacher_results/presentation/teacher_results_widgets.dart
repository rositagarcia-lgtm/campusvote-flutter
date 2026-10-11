import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_motion.dart';
import '../domain/teacher_results.dart';

String _score(double value) => value.toStringAsFixed(1);

BoxDecoration _cardDecoration(ColorScheme scheme) => BoxDecoration(
      color: scheme.surface,
      borderRadius: AppRadii.rLarge,
      border: Border.all(color: scheme.outlineVariant),
    );

/// Promedio general con estrellas y número de evaluaciones.
class ResultsHero extends StatelessWidget {
  const ResultsHero({super.key, required this.results});

  final TeacherResults results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final average = results.overallAverage;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: _cardDecoration(scheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROMEDIO DE TUS CRITERIOS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _score(average),
                style: theme.textTheme.displaySmall
                    ?.copyWith(fontWeight: FontWeight.w800, height: 1),
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('de 5', style: theme.textTheme.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  average >= i - 0.25
                      ? PhosphorIconsFill.star
                      : PhosphorIconsRegular.star,
                  size: 20,
                  color: scheme.primary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.l,
            runSpacing: AppSpacing.s,
            children: [
              _Fact(
                icon: PhosphorIconsRegular.usersThree,
                text: '${results.totalResponses} evaluaciones',
              ),
              if (results.overallRating != null)
                _Fact(
                  icon: PhosphorIconsRegular.star,
                  text:
                      'Calificación general ${_score(results.overallRating!)}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      );
}

/// Mejor y peor criterio, para saber qué mantener y qué trabajar.
class ResultsHighlights extends StatelessWidget {
  const ResultsHighlights({
    super.key,
    required this.strongest,
    required this.weakest,
  });

  final CriterionResult strongest;
  final CriterionResult weakest;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Highlight(
            label: 'Tu fortaleza',
            criterion: strongest,
            icon: PhosphorIconsRegular.trendUp,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: _Highlight(
            label: 'Para mejorar',
            criterion: weakest,
            icon: PhosphorIconsRegular.target,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight({
    required this.label,
    required this.criterion,
    required this.icon,
    required this.color,
  });

  final String label;
  final CriterionResult criterion;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: _cardDecoration(theme.colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.s),
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            criterion.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text('${_score(criterion.average)} de 5',
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Fila con barra de 0 a 5 que se llena al aparecer.
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
