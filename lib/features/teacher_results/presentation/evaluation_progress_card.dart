import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../data/teacher_results_repository.dart';
import '../domain/evaluation_progress.dart';

String _day(DateTime? d) => d == null ? '—' : '${d.day}/${d.month}/${d.year}';

/// Avance de la jornada de evaluación: cuántos de tus alumnos ya te
/// evaluaron en cada curso. Solo conteos, nunca quién ni qué respondió.
class EvaluationProgressCard extends ConsumerWidget {
  const EvaluationProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules =
        ref.watch(teacherEvaluationProgressProvider).valueOrNull ?? const [];
    if (schedules.isEmpty) return const SizedBox.shrink();
    // La jornada más reciente (abierta primero).
    final current = schedules.firstWhere(
      (s) => s.state == JornadaState.open,
      orElse: () => schedules.first,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: _ScheduleCard(schedule: current),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule});

  final ScheduleProgress schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (label, tone) = switch (schedule.state) {
      JornadaState.open => ('Jornada abierta', AppTone.success),
      JornadaState.closed => ('Jornada cerrada', AppTone.neutral),
      JornadaState.upcoming => ('Jornada próxima', AppTone.info),
    };
    final left = schedule.daysLeft;
    final range = 'Del ${_day(schedule.startDate)} al ${_day(schedule.endDate)}'
        '${schedule.state == JornadaState.open && left != null ? (left == 1 ? ' · último día' : ' · quedan $left días') : ''}';
    final total = schedule.eligible;
    final done = schedule.evaluated;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.usersThree, color: scheme.primary),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text('Avance de tu evaluación',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              StatusChip(label: label, tone: tone),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            [if (schedule.periodName.isNotEmpty) schedule.periodName, range]
                .join(' · '),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.m),
          Text('$done de $total alumnos ya te evaluaron',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadii.rSmall,
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          for (final course in schedule.courses)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.courseName,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        if (course.cycle != null)
                          Text('Ciclo ${course.cycle}',
                              style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text('${course.evaluated} de ${course.eligible}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          Text(
            'Solo ves cuántos te evaluaron, nunca quién ni qué respondió.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
