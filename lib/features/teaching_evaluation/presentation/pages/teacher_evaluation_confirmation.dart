part of 'teacher_evaluation_page.dart';

Future<bool?> _showTeacherEvaluationConfirmation(BuildContext context,
    TeachingAssignment assignment, EvaluateState state, String comment) {
  final teacher = assignment.teacherFullName.trim().isEmpty
      ? 'Docente no disponible'
      : assignment.teacherFullName;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      scrollable: true,
      title: const Text('Revisa tu evaluación'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Al enviarla ya no podrás cambiarla. Tu evaluación es anónima para el docente.',
            ),
            const SizedBox(height: AppSpacing.l),
            TeacherEvaluationReviewLine(label: 'Docente', value: teacher),
            const SizedBox(height: AppSpacing.m),
            TeacherEvaluationReviewLine(
                label: 'Curso', value: assignment.courseName),
            const SizedBox(height: AppSpacing.m),
            TeacherEvaluationReviewLine(
              label: 'Criterios',
              value:
                  '${state.answered} de ${state.criteria.length} calificados',
            ),
            const SizedBox(height: AppSpacing.m),
            TeacherEvaluationReviewLine(
                label: 'Calificación general', value: '${state.overall} de 5'),
            const SizedBox(height: AppSpacing.m),
            TeacherEvaluationReviewLine(
              label: 'Comentario',
              value: comment.isEmpty ? 'Sin comentario' : comment,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Seguir editando'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          icon: const Icon(PhosphorIconsRegular.paperPlaneTilt),
          label: const Text('Enviar evaluación'),
        ),
      ],
    ),
  );
}
