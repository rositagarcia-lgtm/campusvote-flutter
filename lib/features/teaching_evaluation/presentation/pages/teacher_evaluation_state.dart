part of 'teacher_evaluation_page.dart';

class _TeacherEvaluationPageState extends ConsumerState<TeacherEvaluationPage> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _commentRestored = false;

  EvaluateTeacherController get _controller =>
      ref.read(evaluateTeacherControllerProvider(widget.assignmentId).notifier);

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  TeachingAssignment? _findAssignment(List<TeachingAssignment> items) {
    for (final assignment in items) {
      if (assignment.id == widget.assignmentId) return assignment;
    }
    return null;
  }

  Future<void> _reviewAndSubmit(
      TeachingAssignment assignment, EvaluateState state) async {
    if (!assignment.canEvaluate) return;
    if (!_formKey.currentState!.validate()) return;
    if (!state.complete || state.overall < 1) {
      // El controlador muestra qué falta.
      await _controller.submit(comment: _commentController.text);
      return;
    }
    final confirmed = await _confirmSelection(assignment, state);
    if (!mounted || confirmed != true) return;
    final saved = await _controller.submit(comment: _commentController.text);
    if (mounted && saved) {
      context.go('/teaching/evaluate/${widget.assignmentId}/success');
    }
  }

  /// Título del grupo al empezar los generales o los de la carrera; solo si
  /// la rúbrica tiene de ambos tipos.
  String? _groupTitle(List<EvaluationCriterion> criteria, int index) {
    final mixed =
        criteria.any((c) => c.isGeneral) && criteria.any((c) => !c.isGeneral);
    if (!mixed) return null;
    final current = criteria[index].isGeneral;
    if (index > 0 && criteria[index - 1].isGeneral == current) return null;
    return current ? 'Generales de la sede' : 'De tu carrera';
  }

  Future<void> _checkStatus() async {
    final ok = await _controller.checkStatus();
    if (ok && mounted) {
      context.go('/teaching/evaluate/${widget.assignmentId}/success');
    }
  }

  Future<bool?> _confirmSelection(
      TeachingAssignment assignment, EvaluateState state) {
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
                  label: 'Calificación general',
                  value: '${state.overall} de 5'),
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

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(teachingListControllerProvider);
    final assignment = _findAssignment(listState.items);
    final state =
        ref.watch(evaluateTeacherControllerProvider(widget.assignmentId));

    if (assignment != null &&
        assignment.canEvaluate &&
        !state.loaded &&
        !state.loading &&
        state.loadError == null) {
      // Carga diferida: no se modifica un provider durante el build.
      Future.microtask(() => _controller.load(assignment));
    }
    if (state.loaded && !_commentRestored) {
      _commentRestored = true;
      _commentController.text = state.initialComment;
    }

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Evaluar docente',
        leading: IconButton(
          tooltip: 'Volver a mis docentes',
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.go('/teaching'),
        ),
      ),
      body: _buildBody(context, state, assignment, listState),
    );
  }

  Widget _buildBody(
    BuildContext context,
    EvaluateState state,
    TeachingAssignment? assignment,
    TeachingListState listState,
  ) {
    if (assignment == null) {
      return listState.loading
          ? const Center(child: CircularProgressIndicator())
          : AppErrorView(
              message: listState.errorMessage ??
                  'No encontramos esta asignación entre tus docentes.',
              onRetry: () => context.go('/teaching'),
              retryLabel: 'Volver a mis docentes',
            );
    }
    if (assignment.evaluated) {
      return const UnavailableEvaluationView(
        title: 'Evaluación completada',
        message: 'El servidor indica que esta asignación ya fue evaluada.',
      );
    }
    if (!assignment.isActive) {
      return const UnavailableEvaluationView(
        title: 'Evaluación no disponible',
        message: 'Esta asignación no está activa y no se puede evaluar ahora.',
      );
    }
    if (!assignment.evaluationOpen) {
      final day = assignment.opensAt;
      return UnavailableEvaluationView(
        title: assignment.opensLater
            ? 'La evaluación aún no empieza'
            : 'La jornada de evaluación terminó',
        message: assignment.opensLater && day != null
            ? 'Podrás evaluar a este docente el ${evaluationDayLabel(day)}.'
            : 'Ya no se reciben evaluaciones para este curso en el periodo.',
      );
    }
    if (state.loadError != null) {
      return AppErrorView(
        message: state.loadError!,
        onRetry: () => _controller.load(assignment),
      );
    }
    if (!state.loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.criteria.isEmpty) {
      return const UnavailableEvaluationView(
        title: 'Rúbrica no disponible',
        message:
            'Tu sede aún no publicó los criterios para evaluar este curso. Vuelve a intentarlo más tarde.',
      );
    }
    return _buildForm(context, state, assignment);
  }

  Widget _buildForm(
    BuildContext context,
    EvaluateState state,
    TeachingAssignment assignment,
  ) {
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
                key: _formKey,
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
                      if (_groupTitle(state.criteria, i) case final title?)
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
                              _controller.setScore(state.criteria[i].id, score),
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
                      onChanged: _controller.setOverall,
                    ),
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
                        onPressed: state.checkingStatus ? null : _checkStatus,
                      ),
                      const SizedBox(height: AppSpacing.s),
                    ],
                    AppButton(
                      label: state.submitting
                          ? 'Enviando evaluación'
                          : 'Revisar y enviar',
                      icon: PhosphorIconsRegular.paperPlaneTilt,
                      isLoading: state.submitting,
                      onPressed: locked || state.saving.isNotEmpty
                          ? null
                          : () => _reviewAndSubmit(assignment, state),
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
