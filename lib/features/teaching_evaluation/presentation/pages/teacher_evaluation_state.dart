part of 'teacher_evaluation_page.dart';

class _TeacherEvaluationPageState extends ConsumerState<TeacherEvaluationPage> {
  int _score = 0;
  bool _scoreError = false;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  TeachingAssignment? get _assignment {
    for (final assignment in ref.read(teachingListControllerProvider).items) {
      if (assignment.id == widget.assignmentId) return assignment;
    }
    return null;
  }

  Future<void> _reviewAndSubmit() async {
    final assignment = _assignment;
    if (assignment == null || !assignment.isActive || assignment.evaluated) {
      return;
    }
    if (_score < 1 || _score > 5) {
      setState(() => _scoreError = true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await _confirmSelection(assignment);
    if (!mounted || confirmed != true) return;

    final saved = await ref
        .read(evaluateTeacherControllerProvider(widget.assignmentId).notifier)
        .submit(score: _score, comment: _commentController.text);
    if (mounted && saved) {
      context.go('/teaching/evaluate/${widget.assignmentId}/success');
    }
  }

  Future<bool?> _confirmSelection(TeachingAssignment assignment) {
    final course = assignment.courseName.trim().isEmpty
        ? 'Curso no disponible'
        : assignment.courseName;
    final teacher = assignment.teacherFullName.trim().isEmpty
        ? 'Docente no disponible'
        : assignment.teacherFullName;
    final comment = _commentController.text.trim();

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
                'Confirma la calificación antes de enviarla. El servidor indicará si quedó registrada.',
              ),
              const SizedBox(height: AppSpacing.l),
              TeacherEvaluationReviewLine(label: 'Docente', value: teacher),
              const SizedBox(height: AppSpacing.m),
              TeacherEvaluationReviewLine(label: 'Asignación', value: course),
              const SizedBox(height: AppSpacing.m),
              TeacherEvaluationReviewLine(label: 'Calificación', value: '$_score de 5'),
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
            icon: const Icon(Icons.send_outlined),
            label: const Text('Enviar evaluación'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(evaluateTeacherControllerProvider(widget.assignmentId));
    final assignment = _assignment;
    final listState = ref.watch(teachingListControllerProvider);

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Evaluar docente',
        leading: IconButton(
          tooltip: 'Volver a mis docentes',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/teaching'),
        ),
      ),
      body: assignment == null && listState.loading
          ? const Center(child: CircularProgressIndicator())
          : assignment == null
              ? AppErrorView(
                  message: listState.errorMessage ??
                      'No encontramos esta asignación entre tus docentes.',
                  onRetry: () => context.go('/teaching'),
                  retryLabel: 'Volver a mis docentes',
                )
              : assignment.evaluated
                  ? const UnavailableEvaluationView(
                      title: 'Evaluación completada',
                      message:
                          'El servidor indica que esta asignación ya fue evaluada.',
                    )
                  : !assignment.isActive
                      ? const UnavailableEvaluationView(
                          title: 'Evaluación no disponible',
                          message:
                              'Esta asignación no está activa y no se puede evaluar ahora.',
                        )
                      : _buildForm(context, state, assignment),
    );
  }

  Widget _buildForm(
    BuildContext context,
    EvaluateState state,
    TeachingAssignment assignment,
  ) {
    final theme = Theme.of(context);
    final locked = state.submitting ||
        state.checkingStatus ||
        state.needsStatusCheck ||
        state.confirmed;
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
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TeacherEvaluationHeader(
                      assignment: assignment,
                      teacherName: teacherName,
                      courseName: courseName,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Semantics(
                      header: true,
                      child: Text(
                        'Califica al docente',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Indica una calificación general. Puedes añadir un comentario de mejora.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    TeacherRatingSelector(
                      value: _score,
                      enabled: !locked,
                      onChanged: (score) => setState(() {
                        _score = score;
                        _scoreError = false;
                      }),
                    ),
                    if (_scoreError) ...[
                      const SizedBox(height: AppSpacing.s),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          'La calificación es obligatoria. Elige de 1 a 5.',
                          key: const ValueKey('teacher-score-error'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.l),
                    AppTextField(
                      label: 'Comentario de mejora (opcional)',
                      hint: 'Escribe una sugerencia concreta y respetuosa.',
                      helperText: 'Hasta 2000 caracteres.',
                      controller: _commentController,
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
                            ? Icons.cloud_sync_outlined
                            : Icons.error_outline_rounded,
                        liveRegion: true,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.l),
                    if (state.needsStatusCheck) ...[
                      AppButton.outlined(
                        label: state.checkingStatus
                            ? 'Consultando el estado'
                            : 'Consultar estado de la evaluación',
                        icon: Icons.refresh_rounded,
                        isLoading: state.checkingStatus,
                        onPressed: state.checkingStatus
                            ? null
                            : () => ref
                                .read(evaluateTeacherControllerProvider(
                                        widget.assignmentId)
                                    .notifier)
                                .checkStatus(),
                      ),
                      const SizedBox(height: AppSpacing.s),
                    ],
                    AppButton(
                      label: state.submitting
                          ? 'Enviando evaluación'
                          : 'Revisar y confirmar',
                      icon: Icons.send_outlined,
                      isLoading: state.submitting,
                      onPressed: locked ? null : _reviewAndSubmit,
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

