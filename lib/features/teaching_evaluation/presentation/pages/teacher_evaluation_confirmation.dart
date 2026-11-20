part of 'teacher_evaluation_page.dart';

Future<bool?> _showTeacherEvaluationConfirmation(BuildContext context,
    TeachingAssignment assignment, EvaluateState state, String comment) {
  final copy = SettingsCopy.of(context);
  final teacher = assignment.teacherFullName.trim().isEmpty
      ? copy.t('Docente no disponible')
      : assignment.teacherFullName;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final dialogCopy = SettingsCopy.of(dialogContext);
      return AlertDialog(
      scrollable: true,
      title: Text(dialogCopy.t('Revisa tu evaluación')),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dialogCopy.t(
                'Al enviarla ya no podrás cambiarla. La institución verá que participaste, pero no tus respuestas individuales.',
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            TeacherEvaluationReviewLine(
                label: dialogCopy.t('Docente'), value: teacher),
            const SizedBox(height: AppSpacing.m),
            TeacherEvaluationReviewLine(
                label: dialogCopy.t('Curso'), value: assignment.courseName),
            const SizedBox(height: AppSpacing.m),
            TeacherEvaluationReviewLine(
              label: dialogCopy.t('Criterios'),
              value: dialogCopy.isEnglish
                  ? '${state.answered} of ${state.criteria.length} rated'
                  : '${state.answered} de ${state.criteria.length} calificados',
            ),
            const SizedBox(height: AppSpacing.m),
            TeacherEvaluationReviewLine(
                label: dialogCopy.t('Calificación general'),
                value: dialogCopy.isEnglish
                    ? '${state.overall} out of 5'
                    : '${state.overall} de 5'),
            const SizedBox(height: AppSpacing.m),
            TeacherEvaluationReviewLine(
              label: dialogCopy.t('Comentario'),
              value: comment.isEmpty
                  ? dialogCopy.t('Sin comentario')
                  : comment,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(dialogCopy.t('Seguir editando')),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          icon: const Icon(PhosphorIconsRegular.paperPlaneTilt),
          label: Text(dialogCopy.t('Enviar evaluación')),
        ),
      ],
    );
    },
  );
}
