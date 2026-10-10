// fair_projects_body.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import 'fair_project_filter.dart';
import 'widgets/fair_actions_bar.dart';
import 'widgets/fair_progress_banner.dart';
import 'widgets/fair_project_card.dart';
import 'widgets/fair_project_filter_bar.dart';

/// Cuerpo de `/jury/fair/:fairId`: cabecera, progreso, accesos y proyectos.
///
/// Se separa de la página porque necesita estado propio (el filtro elegido)
/// mientras la página solo se encarga del refresco, la app bar y los casos de
/// carga.
class FairProjectsBody extends ConsumerStatefulWidget {
  const FairProjectsBody({
    super.key,
    required this.fairId,
    required this.projects,
  });

  final String fairId;
  final List<FairProjectModel> projects;

  @override
  ConsumerState<FairProjectsBody> createState() => _FairProjectsBodyState();
}

class _FairProjectsBodyState extends ConsumerState<FairProjectsBody> {
  FairProjectFilter _filter = FairProjectFilter.all;

  @override
  Widget build(BuildContext context) {
    // El progreso alimenta el banner superior sin pedir un endpoint extra.
    final progress = ref.watch(juryProgressProvider(widget.fairId));
    final evaluations = ref.watch(myEvaluationsProvider(widget.fairId));
    final assignments = ref.watch(juryDashboardProvider).asData?.value;
    final fairName = fairNameForFairId(
      assignments: assignments ?? const <FairAssignmentModel>[],
      fairId: widget.fairId,
    );
    final theme = Theme.of(context);

    // Mientras los estados no llegan, no se afirma «Pendiente»: se sabe si un
    // proyecto está evaluado solo cuando la API lo ha confirmado.
    final known = !evaluations.isLoading &&
        !evaluations.hasError &&
        evaluations.valueOrNull != null;
    final submittedIds = known
        ? evaluations.requireValue
            .where((evaluation) => evaluation.submitted)
            .map((evaluation) => evaluation.projectId)
            .toSet()
        : <String>{};
    final visible = known
        ? filterFairProjects(
            projects: widget.projects,
            filter: _filter,
            submittedIds: submittedIds,
          )
        : widget.projects;

    return PageScrollBody(
      // Siempre desplazable para que el pull-to-refresh funcione con poco
      // contenido.
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'FERIA ASIGNADA',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Semantics(
            header: true,
            child: Text(
              fairName ?? 'Proyectos de tu categoría',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (progress.hasValue) ...[
            FairProgressBanner(progress: progress.requireValue),
            const SizedBox(height: AppSpacing.l),
          ],
          FairActionsBar(fairId: widget.fairId),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            label: 'TU CATEGORÍA',
            title: 'Proyectos aprobados',
            count: visible.length,
          ),
          _FiltersSlot(
            evaluations: evaluations,
            filter: _filter,
            projects: widget.projects,
            submittedIds: submittedIds,
            onRetry: () => ref.invalidate(myEvaluationsProvider(widget.fairId)),
            onSelected: (filter) => setState(() => _filter = filter),
          ),
          if (visible.isEmpty)
            const NoticeBanner(
              tone: AppTone.info,
              icon: PhosphorIconsRegular.funnelSimpleX,
              message: 'No hay proyectos en este filtro.',
            ),
          for (final project in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: FairProjectCard(
                fairId: widget.fairId,
                project: project,
                evaluationSubmitted:
                    known ? submittedIds.contains(project.id) : null,
              ),
            ),
        ],
      ),
    );
  }
}

/// Filtros de la lista, o el motivo por el que aún no se pueden mostrar.
///
/// Los tres estados posibles del endpoint (cargando, fallido, listo) se
/// resuelven aquí para que el cuerpo no crezca con `if` anidados.
class _FiltersSlot extends StatelessWidget {
  const _FiltersSlot({
    required this.evaluations,
    required this.filter,
    required this.projects,
    required this.submittedIds,
    required this.onRetry,
    required this.onSelected,
  });

  final AsyncValue<List<JuryEvaluationSummaryModel>> evaluations;
  final FairProjectFilter filter;
  final List<FairProjectModel> projects;
  final Set<String> submittedIds;
  final VoidCallback onRetry;
  final ValueChanged<FairProjectFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    if (evaluations.isLoading) {
      return const LinearProgressIndicator(minHeight: 2);
    }
    if (evaluations.hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NoticeBanner(
            tone: AppTone.info,
            icon: PhosphorIconsRegular.info,
            message:
                'No pudimos cargar el estado de las rúbricas. Puedes abrir los proyectos y reintentar aquí.',
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(PhosphorIconsRegular.arrowClockwise),
            label: const Text('Reintentar estados'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FairProjectFilterBar(
          selected: filter,
          projects: projects,
          submittedIds: submittedIds,
          onSelected: onSelected,
        ),
        const SizedBox(height: AppSpacing.m),
      ],
    );
  }
}
