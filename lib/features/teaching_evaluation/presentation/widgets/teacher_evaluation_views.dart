import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_status_chip.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/teaching_assignment.dart';

class TeacherEvaluationReviewLine extends StatelessWidget {
  const TeacherEvaluationReviewLine({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      );
}

class TeacherEvaluationHeader extends StatelessWidget {
  const TeacherEvaluationHeader({
    super.key,
    required this.assignment,
    required this.teacherName,
    required this.courseName,
  });

  final TeachingAssignment assignment;
  final String teacherName;
  final String courseName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courseMetadata = [
      if (assignment.courseCode.trim().isNotEmpty) assignment.courseCode,
      if (assignment.cycle > 0) 'Ciclo ${assignment.cycle}',
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DOCENTE A EVALUAR',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          teacherName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(courseName, style: theme.textTheme.bodyLarge),
        if (courseMetadata.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(courseMetadata, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: AppSpacing.m),
        const StatusChip(
          label: 'Pendiente',
          tone: AppTone.primary,
          icon: Icons.rate_review_outlined,
        ),
      ],
    );
  }
}

class UnavailableEvaluationView extends StatelessWidget {
  const UnavailableEvaluationView({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => AppEmptyView(
        icon: Icons.assignment_outlined,
        title: title,
        message: message,
        actionLabel: 'Volver a mis docentes',
        onAction: () => context.go('/teaching'),
        overline: 'ESTADO DE LA ASIGNACIÓN',
      );
}
