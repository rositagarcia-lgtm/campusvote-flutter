part of '../teacher_results_widgets.dart';

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
            'ACUMULADO DE TODOS TUS CURSOS Y PERIODOS',
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
