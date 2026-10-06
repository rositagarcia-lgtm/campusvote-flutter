import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../domain/entities/teaching_assignment.dart';

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({super.key, required this.assignment});

  final TeachingAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = assignment.isActive && !assignment.evaluated;
    final (statusLabel, tone, statusIcon) = assignment.evaluated
        ? ('Completada', AppTone.success, Icons.check_circle_outline_rounded)
        : assignment.isActive
            ? ('Por evaluar', AppTone.primary, Icons.rate_review_outlined)
            : ('No disponible', AppTone.neutral, Icons.lock_outline_rounded);
    final courseName = assignment.courseName.trim().isEmpty
        ? 'Curso sin nombre'
        : assignment.courseName;
    final teacherName = assignment.teacherFullName.trim().isEmpty
        ? 'Nombre del docente no disponible'
        : assignment.teacherFullName;
    final courseMetadata = [
      if (assignment.courseCode.trim().isNotEmpty) assignment.courseCode,
      if (assignment.cycle > 0) 'Ciclo ${assignment.cycle}',
    ].join(' · ');
    final muted = appMuted(theme.brightness == Brightness.dark);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                Icon(Icons.person_outline_rounded,
                    size: AppDimensions.iconSmall, color: muted),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    teacherName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (courseMetadata.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(courseMetadata, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.m),
            StatusChip(label: statusLabel, tone: tone, icon: statusIcon),
            if (enabled) ...[
              const SizedBox(height: AppSpacing.l),
              AppButton.outlined(
                label: 'Evaluar docente',
                icon: Icons.arrow_forward_rounded,
                dense: true,
                onPressed: () =>
                    context.go('/teaching/evaluate/${assignment.id}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
