import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../providers/jury_providers.dart';
import '../providers/jury_state.dart';
import '../widgets/project_status_chip.dart';
import '../widgets/rubric_criterion_tile.dart';

/// `/jury/fair/:fairId/project/:projectId/rubric`
///
/// Formulario dinámico sobre `rubric.criteria[]`. El control es un
/// interruptor porque el backend guarda un checklist (`checked`), calcula el
/// score 0–20 y rechaza con 400 cualquier campo extra (`schema .strict()`),
/// por eso no hay slider ni comentario por criterio.
class RubricEvaluationPage extends ConsumerWidget {
  const RubricEvaluationPage({
    super.key,
    required this.fairId,
    required this.projectId,
  });

  final String fairId;
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = RubricArgs(fairId: fairId, projectId: projectId);
    final state = ref.watch(rubricFormProvider(args));
    final controller = ref.read(rubricFormProvider(args).notifier);

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Rúbrica',
        actions: [
          IconButton(
            tooltip: 'Votar en esta feria',
            icon: const Icon(Icons.how_to_vote_rounded),
            onPressed: () => context.push('/jury/fair/$fairId/vote'),
          ),
        ],
      ),
      body: state.loading
          ? const AppLoader()
          : !state.hasData
              ? AppErrorView(
                  message: state.errorMessage ?? 'No se pudo cargar la rúbrica',
                  onRetry: controller.load,
                )
              : _RubricForm(
                  state: state,
                  controller: controller,
                ),
    );
  }
}

class _RubricForm extends StatelessWidget {
  const _RubricForm({required this.state, required this.controller});

  final RubricFormState state;
  final RubricFormController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final evaluation = state.evaluation!;
    final criteria = evaluation.rubric.criteria;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              if (evaluation.projectName != null) ...[
                Text(
                  evaluation.projectName!,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.s),
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  children: [
                    if (evaluation.projectStatus != null)
                      ProjectStatusChip(status: evaluation.projectStatus!),
                    if (evaluation.categoryName != null)
                      Text(
                        evaluation.categoryName!,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              _ScoreCard(state: state),
              const SizedBox(height: AppSpacing.l),
              if (state.submitted) const _LockedNotice(),
              if (state.errorMessage != null) ...[
                _Banner(
                  text: state.errorMessage!,
                  background: theme.colorScheme.errorContainer,
                  foreground: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              if (state.successMessage != null) ...[
                _Banner(text: state.successMessage!),
                const SizedBox(height: AppSpacing.m),
              ],
              Text(
                evaluation.rubric.name.isEmpty
                    ? 'Criterios de evaluación'
                    : evaluation.rubric.name,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                '${state.checkedCount} de ${criteria.length} criterios marcados',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.m),
              for (final criterion in criteria)
                RubricCriterionTile(
                  position: criterion.position,
                  title: criterion.name,
                  description: criterion.description,
                  value: state.answers[criterion.id] ?? false,
                  enabled: !state.locked,
                  onChanged: (_) => controller.toggle(criterion.id),
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
        if (!state.submitted) _ActionsBar(state: state, controller: controller),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.state});

  final RubricFormState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final evaluation = state.evaluation!;
    final score = evaluation.score;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Puntaje', style: theme.textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    // El score solo existe cuando la hoja está finalizada.
                    score == null
                        ? 'Pendiente de finalizar'
                        : '${score.toStringAsFixed(1)} / 20',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            if (evaluation.submittedAt != null)
              Text(
                'Finalizado',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }
}

class _LockedNotice extends StatelessWidget {
  const _LockedNotice();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: _Banner(
        text: 'Esta evaluación ya fue finalizada y no admite cambios.',
        background: Colors.amber.shade50,
        foreground: Colors.amber.shade900,
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, this.background, this.foreground});

  final String text;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? Theme.of(context).textTheme.bodyMedium?.color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: background ?? Colors.grey.shade100,
        borderRadius: AppRadii.rMedium,
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ActionsBar extends StatelessWidget {
  const _ActionsBar({required this.state, required this.controller});

  final RubricFormState state;
  final RubricFormController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Guardar borrador',
                onPressed: state.saving
                    ? null
                    : () => controller.save(finalize: false),
                isLoading: state.saving,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: AppButton(
                label: 'Finalizar',
                // El backend exige cubrir TODOS los criterios activos.
                onPressed: state.canFinalize
                    ? () => controller.save(finalize: true)
                    : null,
                isLoading: state.saving,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
