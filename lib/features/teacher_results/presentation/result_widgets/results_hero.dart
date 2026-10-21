part of '../teacher_results_widgets.dart';

String _score(double value) => value.toStringAsFixed(1);

BoxDecoration _cardDecoration(ColorScheme scheme) => BoxDecoration(
      color: scheme.surface,
      borderRadius: AppRadii.rLarge,
      border: Border.all(color: scheme.outlineVariant),
    );

/// Promedio agregado, con escala y cantidad de respuestas explícitas.
class ResultsHero extends StatelessWidget {
  const ResultsHero({super.key, required this.results});

  final TeacherResults results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final average = results.overallAverage;
    return Semantics(
      label: 'Promedio general ${_score(average)} de 5. '
          '${results.totalResponses} evaluaciones.',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            scheme.primary.withValues(alpha: 0.08),
            scheme.surface,
          ),
          borderRadius: AppRadii.rXLarge,
          border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TU DESEMPEÑO DOCENTE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                )),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Promedio general',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Todos tus cursos y periodos',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          )),
                      const SizedBox(height: AppSpacing.m),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_score(average),
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              )),
                          const SizedBox(width: AppSpacing.xs),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text('/ 5',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 76,
                  height: 76,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: (average / 5).clamp(0, 1),
                          strokeWidth: 7,
                          strokeCap: StrokeCap.round,
                          color: scheme.primary,
                          backgroundColor:
                              scheme.primary.withValues(alpha: 0.13),
                        ),
                      ),
                      Icon(PhosphorIconsFill.star,
                          size: 27, color: scheme.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Divider(height: 1, color: scheme.outlineVariant),
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
                    text: 'Calificación general '
                        '${_score(results.overallRating!)} de 5',
                  ),
              ],
            ),
          ],
        ),
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
