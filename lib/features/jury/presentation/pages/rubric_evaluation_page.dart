import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../providers/jury_providers.dart';
import '../providers/jury_state.dart';
import '../widgets/project_status_chip.dart';
import '../widgets/rubric_criterion_tile.dart';
import '../widgets/rubric_form_widgets.dart';

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
            icon: const Icon(PhosphorIconsFill.checkSquareOffset),
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
              ConstrainedContent(
                maxWidth: kListMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (evaluation.projectName != null) ...[
                      Text(
                        'EVALUACIÓN DEL PROYECTO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        evaluation.projectName!,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Wrap(
                        spacing: AppSpacing.s,
                        runSpacing: AppSpacing.s,
                        children: [
                          if (evaluation.projectStatus != null)
                            ProjectStatusChip(
                                status: evaluation.projectStatus!),
                          if (evaluation.categoryName != null)
                            Text(
                              evaluation.categoryName!,
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),
                    ],
                    AppMotion.reveal(0, RubricScoreCard(state: state)),
                    const SizedBox(height: AppSpacing.l),
                    if (state.submitted)
                      const NoticeBanner(
                        message:
                            'Esta evaluación ya fue finalizada y no admite cambios.',
                        tone: AppTone.warning,
                      ),
                    if (state.errorMessage != null) ...[
                      if (state.submitted) const SizedBox(height: AppSpacing.m),
                      NoticeBanner(
                        message: state.errorMessage!,
                        tone: AppTone.danger,
                        liveRegion: true,
                      ),
                    ],
                    if (state.successMessage != null) ...[
                      if (state.submitted) const SizedBox(height: AppSpacing.m),
                      NoticeBanner(
                        message: state.successMessage!,
                        tone: AppTone.success,
                        liveRegion: true,
                      ),
                    ],
                    Text(
                      evaluation.rubric.name.isEmpty
                          ? 'Criterios de evaluación'
                          : evaluation.rubric.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    for (var i = 0; i < criteria.length; i++)
                      AppMotion.reveal(
                        i + 1,
                        RubricCriterionTile(
                          position: criteria[i].position,
                          title: criteria[i].name,
                          description: criteria[i].description,
                          value: state.answers[criteria[i].id] ?? false,
                          enabled: !state.locked,
                          onChanged: (_) => controller.toggle(criteria[i].id),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!state.submitted)
          RubricActionsBar(state: state, controller: controller),
      ],
    );
  }
}
