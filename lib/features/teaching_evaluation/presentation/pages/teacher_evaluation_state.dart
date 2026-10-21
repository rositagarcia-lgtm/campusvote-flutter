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
    final confirmed = await _showTeacherEvaluationConfirmation(
        context, assignment, state, _commentController.text.trim());
    if (!mounted || confirmed != true) return;
    final saved = await _controller.submit(comment: _commentController.text);
    if (mounted && saved) {
      context.go('/teaching/evaluate/${widget.assignmentId}/success');
    }
  }

  Future<void> _checkStatus() async {
    final ok = await _controller.checkStatus();
    if (ok && mounted) {
      context.go('/teaching/evaluate/${widget.assignmentId}/success');
    }
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
  ) =>
      TeacherEvaluationForm(
        state: state,
        assignment: assignment,
        formKey: _formKey,
        commentController: _commentController,
        onScoreChanged: _controller.setScore,
        onOverallChanged: _controller.setOverall,
        onCheckStatus: _checkStatus,
        onSubmit: () => _reviewAndSubmit(assignment, state),
      );
}
