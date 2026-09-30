import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../state/evaluate_controller.dart';
import '../state/teaching_list_controller.dart';

/// Pantalla de evaluación docente (1-5 estrellas + comentario opcional).
class TeacherEvaluationPage extends ConsumerStatefulWidget {
  final String assignmentId;
  const TeacherEvaluationPage({super.key, required this.assignmentId});

  @override
  ConsumerState<TeacherEvaluationPage> createState() =>
      _TeacherEvaluationPageState();
}

class _TeacherEvaluationPageState extends ConsumerState<TeacherEvaluationPage> {
  int _score = 0;
  final _commentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  TeachingAssignment? get _assignment {
    final list = ref.read(teachingListControllerProvider).items;
    for (final a in list) {
      if (a.id == widget.assignmentId) return a;
    }
    return null;
  }

  Future<void> _submit() async {
    if (_score < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una calificación de 1 a 5 estrellas'),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(evaluateTeacherControllerProvider(widget.assignmentId).notifier)
        .submit(score: _score, comment: _commentCtrl.text);
    if (!mounted) return;
    if (ok) {
      context.go('/teaching/evaluate/${widget.assignmentId}/success');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state =
        ref.watch(evaluateTeacherControllerProvider(widget.assignmentId));
    final assignment = _assignment;

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Evaluar docente',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/teaching'),
        ),
      ),
      body: assignment == null
          ? AppErrorView(
              message: 'No encontramos esta asignación.',
              onRetry: () => context.go('/teaching'),
            )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.l),
                children: [
                  _TeacherHeader(assignment: assignment),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    '¿Cómo calificas el desempeño de ${assignment.teacherFirstName} '
                    'en ${assignment.courseName}?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _StarsSelector(
                    score: _score,
                    onChanged: state.submitting
                        ? (_) {}
                        : (s) => setState(() => _score = s),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Form(
                    key: _formKey,
                    child: AppTextField(
                      label: 'Comentario (opcional)',
                      hint: 'Comparte con la institución un comentario breve…',
                      controller: _commentCtrl,
                      maxLines: 4,
                      maxLength: 2000,
                      validator: (value) {
                        if (value != null && value.trim().length > 2000) {
                          return 'Máximo 2000 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.m),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: const BoxDecoration(
                        color: AppColors.dangerSoft,
                        borderRadius: AppRadii.rMedium,
                      ),
                      child: Text(
                        state.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Enviar evaluación',
                    icon: Icons.send_rounded,
                    isLoading: state.submitting,
                    onPressed: state.submitting ? null : _submit,
                  ),
                ],
              ),
            ),
    );
  }
}

class _TeacherHeader extends StatelessWidget {
  final TeachingAssignment assignment;
  const _TeacherHeader({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: context.brandPrimarySoft,
        borderRadius: AppRadii.rLarge,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 32,
              color: context.brandPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.teacherFullName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${assignment.courseName} · ${assignment.courseCode} · '
                  'Ciclo ${assignment.cycle}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarsSelector extends StatelessWidget {
  final int score;
  final ValueChanged<int> onChanged;

  const _StarsSelector({required this.score, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final primary = context.brandPrimary;
    final faint = Theme.of(context).textTheme.bodySmall?.color;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            key: ValueKey('star-$i'),
            iconSize: 40,
            onPressed: () => onChanged(i),
            icon: Icon(
              i <= score
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: i <= score ? primary : faint,
            ),
          ),
      ],
    );
  }
}