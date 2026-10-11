import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../domain/entities/teacher_evaluation_form.dart';
import 'teacher_rating_selector.dart';

const _months = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', //
  'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

/// "15 de octubre" (la jornada de evaluación es un día de calendario).
String evaluationDayLabel(DateTime day) =>
    '${day.day} de ${_months[day.month - 1]}';

/// Avance de la rúbrica: cuántos criterios ya calificó el alumno.
class EvaluationProgress extends StatelessWidget {
  const EvaluationProgress({
    super.key,
    required this.answered,
    required this.total,
    required this.saving,
  });

  final int answered;
  final int total;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = total > 0 && answered == total;
    return Semantics(
      liveRegion: true,
      label: '$answered de $total criterios calificados',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                done
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIconsRegular.listChecks,
                size: 18,
                color: done ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  '$answered de $total criterios',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: total == 0 ? 0 : answered / total),
              duration:
                  AppMotion.reduced(context) ? Duration.zero : AppMotion.medium,
              curve: AppMotion.emphasized,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                color: scheme.primary,
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            saving
                ? 'Guardando tu respuesta…'
                : 'Cada respuesta se guarda al marcarla.',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Un criterio de la rúbrica con su calificación de 1 a 5.
class CriterionRatingCard extends StatelessWidget {
  const CriterionRatingCard({
    super.key,
    required this.index,
    required this.criterion,
    required this.value,
    required this.enabled,
    required this.saving,
    required this.onChanged,
  });

  final int index;
  final EvaluationCriterion criterion;
  final int value;
  final bool enabled;
  final bool saving;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final answered = value > 0;
    return AnimatedContainer(
      duration: AppMotion.reduced(context) ? Duration.zero : AppMotion.medium,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(
          color: answered
              ? scheme.primary.withValues(alpha: 0.55)
              : scheme.outlineVariant,
        ),
      ),
      // El número va en el título: las cinco estrellas necesitan todo el
      // ancho en pantallas de 320 px.
      child: Stack(
        children: [
          TeacherRatingSelector(
            title: '$index. ${criterion.name}',
            description: criterion.description,
            value: value,
            enabled: enabled,
            onChanged: onChanged,
          ),
          if (saving)
            const Positioned(
              top: 2,
              right: 0,
              child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
