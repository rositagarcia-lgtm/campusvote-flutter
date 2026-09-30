import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../state/fair_projects_controller.dart';
import '../state/rubric_controller.dart';

/// Pantalla de evaluación CHECKLIST del JURY.
///
/// - Carga la rúbrica configurada por el ADMIN (criterios activos).
/// - Carga (si existe) la hoja de respuestas del JURY.
/// - Permite marcar/desmarcar cada criterio (CHECKLIST, sin puntaje manual).
/// - Botón "Guardar" persiste como borrador (NO finaliza).
/// - Botón "Finalizar rúbrica" requiere TODOS los activos respondidos
///   y marca `submitted_at` (inmutable después).
class RubricPage extends ConsumerStatefulWidget {
  final String fairId;
  final String projectId;
  const RubricPage({
    super.key,
    required this.fairId,
    required this.projectId,
  });

  @override
  ConsumerState<RubricPage> createState() => _RubricPageState();
}

class _RubricPageState extends ConsumerState<RubricPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(rubricControllerProvider((widget.fairId, widget.projectId))
              .notifier)
          .load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      rubricControllerProvider((widget.fairId, widget.projectId)),
    );
    final ctrl = ref.read(
      rubricControllerProvider((widget.fairId, widget.projectId)).notifier,
    );
    final rubric = state.rubric;

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: rubric == null ? 'Rúbrica' : rubric.name,
      ),
      body: _Body(state: state, ctrl: ctrl, fairId: widget.fairId, projectId: widget.projectId),
    );
  }
}

class _Body extends ConsumerWidget {
  final RubricState state;
  final RubricController ctrl;
  final String fairId;
  final String projectId;
  const _Body({
    required this.state,
    required this.ctrl,
    required this.fairId,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.loading) return const AppLoader();
    if (state.errorMessage != null && state.rubric == null) {
      return AppErrorView(
        message: state.errorMessage!,
        onRetry: ctrl.load,
      );
    }
    final rubric = state.rubric;
    if (rubric == null || rubric.activeCriteria.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_rounded, size: 48),
              const SizedBox(height: AppSpacing.m),
              Text(
                'Aún no hay rúbrica configurada',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.l),
              AppButton(
                label: 'Volver',
                icon: Icons.arrow_back_rounded,
                onPressed: () =>
                    context.go('/juries/fairs/$fairId/projects'),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                _StatusBanner(submitted: state.submitted, total: rubric.activeCriteria.length, checked: state.checkedCount),
                const SizedBox(height: AppSpacing.l),
                const AppSectionTitle(title: 'Criterios'),
                for (final c in rubric.activeCriteria)
                  _ChecklistTile(
                    criterionId: c.id,
                    name: c.name,
                    description: c.description,
                    checked: state.answers[c.id] ?? false,
                    disabled: state.submitted,
                    onChanged: (v) => ctrl.toggleAnswer(c.id, v ?? false),
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
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
          _Footer(
            state: state,
            ctrl: ctrl,
            fairId: fairId,
            projectId: projectId,
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool submitted;
  final int total;
  final int checked;

  const _StatusBanner({
    required this.submitted,
    required this.total,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg, icon) = submitted
        ? (
            'Rúbrica finalizada — no se puede editar',
            AppColors.successSoft,
            AppColors.success,
            Icons.lock_rounded,
          )
        : (
            'Marca los criterios cumplidos. Luego pulsa "Guardar" o "Finalizar".',
            context.brandPrimarySoft,
            context.brandPrimary,
            Icons.edit_note_rounded,
          );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.rMedium,
      ),
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: Text(label, style: TextStyle(color: fg))),
          Text(
            '$checked / $total',
            style: TextStyle(color: fg, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final String criterionId;
  final String name;
  final String? description;
  final bool checked;
  final bool disabled;
  final ValueChanged<bool?> onChanged;

  const _ChecklistTile({
    required this.criterionId,
    required this.name,
    this.description,
    required this.checked,
    required this.disabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.rMedium,
        child: InkWell(
          borderRadius: AppRadii.rMedium,
          onTap: disabled ? null : () => onChanged(!checked),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: checked,
                  onChanged: disabled ? null : (v) => onChanged(v),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      if (description != null && description!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.inkFaint,
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final RubricState state;
  final RubricController ctrl;
  final String fairId;
  final String projectId;
  const _Footer({
    required this.state,
    required this.ctrl,
    required this.fairId,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    if (state.submitted) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: AppButton(
            label: 'Volver a proyectos',
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.go('/juries/fairs/$fairId/projects'),
          ),
        ),
      );
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Expanded(
              child: AppButton.outlined(
                label: 'Guardar',
                icon: Icons.save_outlined,
                isLoading: state.saving,
                onPressed: () async {
                  await ctrl.save(finalize: false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Borrador guardado')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: AppButton(
                label: 'Finalizar',
                icon: Icons.check_rounded,
                isLoading: state.saving,
                onPressed: state.saving
                    ? null
                    : () async {
                        final ok = await ctrl.save(finalize: true);
                        if (!context.mounted) return;
                        if (ok) {
                          // Marca localmente en el listado de proyectos.
                          ProviderScope.containerOf(context, listen: false)
                              .read(fairProjectsControllerProvider(fairId)
                                  .notifier)
                              .markFinalized(projectId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Rúbrica finalizada')),
                          );
                          // Vuelve al listado.
                          context.go('/juries/fairs/$fairId/projects');
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
