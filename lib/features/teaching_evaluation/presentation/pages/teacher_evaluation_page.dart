import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../state/evaluate_controller.dart';
import '../state/teaching_list_controller.dart';
import '../widgets/teacher_rating_selector.dart';

/// Formulario de calificación general y comentario opcional del estudiante.
class TeacherEvaluationPage extends ConsumerStatefulWidget {
  const TeacherEvaluationPage({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  ConsumerState<TeacherEvaluationPage> createState() =>
      _TeacherEvaluationPageState();
}

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
              _ReviewLine(label: 'Docente', value: teacher),
              const SizedBox(height: AppSpacing.m),
              _ReviewLine(label: 'Asignación', value: course),
              const SizedBox(height: AppSpacing.m),
              _ReviewLine(label: 'Calificación', value: '$_score de 5'),
              const SizedBox(height: AppSpacing.m),
              _ReviewLine(
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
                  ? const _UnavailableEvaluation(
                      title: 'Evaluación completada',
                      message:
                          'El servidor indica que esta asignación ya fue evaluada.',
                    )
                  : !assignment.isActive
                      ? const _UnavailableEvaluation(
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
                    _TeacherHeader(
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

class _ReviewLine extends StatelessWidget {
  const _ReviewLine({required this.label, required this.value});

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

class _TeacherHeader extends StatelessWidget {
  const _TeacherHeader({
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

class _UnavailableEvaluation extends StatelessWidget {
  const _UnavailableEvaluation({required this.title, required this.message});

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
