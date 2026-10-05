import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/fade_slide.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import '../widgets/fair_projects_widgets.dart';
import '../widgets/project_card.dart';
import '../../../settings/presentation/settings_copy.dart';

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
      appBar: buildCampusVoteAppBar(context,
          title: SettingsCopy.of(context).t('Proyectos')),
      body: RefreshIndicator(
        onRefresh: () async => reload(),
        child: _bodyFor(context, fairId, projects, reload),
      ),
    );
  }
}

Widget _bodyFor(
  BuildContext context,
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
        return AppEmptyView(
          icon: Icons.inventory_2_outlined,
          message: SettingsCopy.of(context)
              .t('No tienes proyectos aprobados para evaluar en esta feria.'),
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

    return PageScrollBody(
      // Siempre desplazable para que el pull-to-refresh funcione con poco
      // contenido.
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (progress.hasValue) ...[
            FadeSlide(
              child: ProgressBanner(progress: progress.requireValue),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          FadeSlide(
            delay: const Duration(milliseconds: 80),
            child: FairActionsBar(fairId: fairId),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
              label: SettingsCopy.of(context).t('Proyectos'),
              count: projects.length),
          for (var i = 0; i < projects.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: FadeSlide(
                // Tope de 360 ms para que las listas largas no demoren.
                delay: Duration(
                  milliseconds: 160 + (i * 60).clamp(0, 360),
                ),
                child: ProjectCard(fairId: fairId, project: projects[i]),
              ),
            ),
        ],
      ),
    );
  }
}
