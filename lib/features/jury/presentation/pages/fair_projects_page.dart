import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import '../widgets/fair_projects_widgets.dart';
import '../widgets/project_card.dart';

/// `/jury/fair/:fairId` — proyectos de la feria.
///
/// El backend ya devuelve SOLO los proyectos aprobados de las categorías
/// asignadas al jurado, así que aquí no se re-filtra (regla 7).
class FairProjectsPage extends ConsumerWidget {
  const FairProjectsPage({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(fairProjectsProvider(fairId));
    void reload() => ref.invalidate(fairProjectsProvider(fairId));

    return Scaffold(
      // Progreso, votar y resultados viven ahora en la barra de accesos del
      // cuerpo, con etiqueta visible, en lugar de tres íconos sin texto.
      appBar: buildCampusVoteAppBar(context, title: 'Proyectos'),
      body: RefreshIndicator(
        onRefresh: () async => reload(),
        child: _bodyFor(fairId, projects, reload),
      ),
    );
  }
}

Widget _bodyFor(
  String fairId,
  AsyncValue<List<FairProjectModel>> projects,
  VoidCallback onRetry,
) {
  switch (projects) {
    case AsyncLoading():
      return const AppLoader();
    case AsyncError(:final error):
      return AppErrorView(
        message: describeJuryError(error),
        onRetry: onRetry,
      );
    case AsyncData(:final value):
      if (value.isEmpty) {
        return const AppEmptyView(
          icon: Icons.inventory_2_outlined,
          message: 'No tienes proyectos aprobados para evaluar en esta feria.',
        );
      }
      return _ProjectsList(fairId: fairId, projects: value);
    default:
      return const AppLoader();
  }
}

class _ProjectsList extends ConsumerWidget {
  const _ProjectsList({required this.fairId, required this.projects});

  final String fairId;
  final List<FairProjectModel> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // El progreso alimenta el banner superior sin pedir un endpoint extra.
    final progress = ref.watch(juryProgressProvider(fairId));
    final assignments = ref.watch(juryDashboardProvider).asData?.value;
    String? fairName;
    for (final assignment in assignments ?? const <FairAssignmentModel>[]) {
      if (assignment.fairId == fairId) {
        fairName = assignment.name;
        break;
      }
    }
    final theme = Theme.of(context);

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
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (progress.hasValue) ...[
            ProgressBanner(progress: progress.requireValue),
            const SizedBox(height: AppSpacing.l),
          ],
          FairActionsBar(fairId: fairId),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            label: 'TU CATEGORÍA',
            title: 'Proyectos aprobados',
            count: projects.length,
          ),
          for (var i = 0; i < projects.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: ProjectCard(fairId: fairId, project: projects[i]),
            ),
        ],
      ),
    );
  }
}
