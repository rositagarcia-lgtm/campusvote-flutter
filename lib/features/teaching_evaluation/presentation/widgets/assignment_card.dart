import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../domain/entities/teaching_assignment.dart';

/// Fila de una asignación docente.
///
/// Formato de lista institucional: mosaico con el código del curso, curso y
/// docente al centro y el estado/acción a la derecha. Toda la fila se toca
/// para evaluar; el estado se lee en texto, no solo por color.
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({super.key, required this.assignment});

  final TeachingAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = assignment.isActive && !assignment.evaluated;
    final tone = assignment.evaluated
        ? AppColors.success
        : assignment.isActive
            ? scheme.primary
            : scheme.onSurfaceVariant;

    final courseName = assignment.courseName.trim().isEmpty
        ? 'Curso sin nombre'
        : assignment.courseName;
    final teacherName = assignment.teacherFullName.trim().isEmpty
        ? 'Docente por confirmar'
        : assignment.teacherFullName;
    final meta = [
      if (assignment.courseCode.trim().isNotEmpty) assignment.courseCode,
      if (assignment.cycle > 0) 'Ciclo ${assignment.cycle}',
    ].join(' · ');
    final status = assignment.evaluated
        ? 'Evaluado'
        : assignment.isActive
            ? 'Pendiente'
            : 'No disponible';

    void open() => context.go('/teaching/evaluate/${assignment.id}');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Semantics(
        button: enabled,
        label: '$courseName. $teacherName. $status',
        excludeSemantics: true,
        child: Pressable(
          onTap: enabled ? open : null,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: AppRadii.rLarge,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                _CourseTile(
                  code: assignment.courseCode,
                  name: courseName,
                  color: tone,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        teacherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      if (meta.isNotEmpty)
                        Text(meta, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                _Trailing(
                  enabled: enabled,
                  evaluated: assignment.evaluated,
                  label: status,
                  color: tone,
                  onTap: open,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mosaico con el código del curso (o sus iniciales) en el color del estado.
class _CourseTile extends StatelessWidget {
  const _CourseTile({
    required this.code,
    required this.name,
    required this.color,
  });

  final String code;
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final digits = RegExp(r'\d+').firstMatch(code)?.group(0);
    final initials = name
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final label = digits ?? (initials.isEmpty ? '—' : initials);
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.12), scheme.surface),
        borderRadius: AppRadii.rMedium,
      ),
      child: Text(
        label,
        maxLines: 1,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
      ),
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({
    required this.enabled,
    required this.evaluated,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final bool enabled;
  final bool evaluated;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (enabled) {
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          shape: const StadiumBorder(),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        child: const Text('Evaluar'),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          evaluated
              ? PhosphorIconsFill.checkCircle
              : PhosphorIconsRegular.lockSimple,
          size: 22,
          color: color,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
