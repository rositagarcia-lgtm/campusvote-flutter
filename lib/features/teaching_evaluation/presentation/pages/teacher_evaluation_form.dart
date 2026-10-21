part of 'teacher_evaluation_page.dart';

String? _evaluationGroupTitle(List<EvaluationCriterion> criteria, int index) {
  final mixed = criteria.any((criterion) => criterion.isGeneral) &&
      criteria.any((criterion) => !criterion.isGeneral);
  if (!mixed) return null;
  final current = criteria[index].isGeneral;
  if (index > 0 && criteria[index - 1].isGeneral == current) return null;
  return current ? 'Generales de la sede' : 'De tu carrera';
}

class TeacherEvaluationForm extends StatelessWidget {
  const TeacherEvaluationForm({
    super.key,
    required this.state,
    required this.assignment,
    required this.formKey,
    required this.commentController,
    required this.onScoreChanged,
    required this.onOverallChanged,
    required this.onCheckStatus,
    required this.onSubmit,
  });

  final EvaluateState state;
  final TeachingAssignment assignment;
  final GlobalKey<FormState> formKey;
  final TextEditingController commentController;
  final void Function(String criterionId, int score) onScoreChanged;
  final ValueChanged<int> onOverallChanged;
  final VoidCallback onCheckStatus;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locked = state.locked;
    final teacherName = assignment.teacherFullName.trim().isEmpty
        ? 'Docente no disponible'
        : assignment.teacherFullName;
    final courseName = assignment.courseName.trim().isEmpty
        ? 'Curso no disponible'
        : assignment.courseName;

    return SafeArea(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppMotion.reveal(
                      0,
                      TeacherEvaluationHeader(
                        assignment: assignment,
                        teacherName: teacherName,
                        courseName: courseName,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    EvaluationProgress(
                      answered: state.answered,
                      total: state.criteria.length,
                      saving: state.saving.isNotEmpty,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    for (var i = 0; i < state.criteria.length; i++) ...[
                      if (_evaluationGroupTitle(state.criteria, i)
                          case final title?)
                        CriteriaGroupTitle(title: title),
                      AppMotion.reveal(
                        i + 1,
                        CriterionRatingCard(
                          index: i + 1,
                          criterion: state.criteria[i],
                          value: state.scores[state.criteria[i].id] ?? 0,
                          enabled: !locked,
                          saving: state.saving.contains(state.criteria[i].id),
                          onChanged: (score) =>
                              onScoreChanged(state.criteria[i].id, score),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                    ],
                    const SizedBox(height: AppSpacing.l),
                    Semantics(
                      header: true,
                      child: Text(
                        'Para terminar',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TeacherRatingSelector(
                      value: state.overall,
                      enabled: !locked,
                      onChanged: onOverallChanged,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    AppTextField(
                      label: 'Comentario de mejora (opcional)',
                      hint: 'Escribe una sugerencia concreta y respetuosa.',
                      helperText: 'Hasta 2000 caracteres.',
                      controller: commentController,
                      maxLines: 5,
                      maxLength: 2000,
                      enabled: !locked,
                      textInputAction: TextInputAction.newline,
                      validator: (value) => value != null &&
                              value.trim().length > 2000
                          ? 'El comentario no puede superar 2000 caracteres.'
                          : null,
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.l),
                      NoticeBanner(
                        message: state.errorMessage!,
                        tone: state.needsStatusCheck ||
                                state.statusConfirmedPending
                            ? AppTone.warning
                            : AppTone.danger,
                        icon: state.needsStatusCheck
                            ? PhosphorIconsRegular.cloudArrowUp
                            : PhosphorIconsRegular.warningCircle,
                        liveRegion: true,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.l),
                    if (state.needsStatusCheck) ...[
                      AppButton.outlined(
                        label: state.checkingStatus
                            ? 'Consultando el estado'
                            : 'Consultar estado de la evaluación',
                        icon: PhosphorIconsRegular.arrowClockwise,
                        isLoading: state.checkingStatus,
                        onPressed: state.checkingStatus ? null : onCheckStatus,
                      ),
                      const SizedBox(height: AppSpacing.s),
                    ],
                    AppButton(
                      label: state.submitting
                          ? 'Enviando evaluación'
                          : 'Revisar y enviar',
                      icon: PhosphorIconsRegular.paperPlaneTilt,
                      isLoading: state.submitting,
                      onPressed:
                          locked || state.saving.isNotEmpty ? null : onSubmit,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
