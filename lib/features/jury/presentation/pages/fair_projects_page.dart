import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/organization_panel_app_bar.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import '../projects/fair_projects_body.dart';

/// `/jury/fair/:fairId` — proyectos de la feria.
///
/// El backend ya devuelve SOLO los proyectos aprobados de las categorías
/// asignadas al jurado, así que aquí no se re-filtra (regla 7). Esta página solo
/// compone: refresco, app bar y los estados de carga/error/vacío.
class FairProjectsPage extends ConsumerWidget {
  const FairProjectsPage({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(fairProjectsProvider(fairId));
    final branding = ref.watch(brandingControllerProvider);
    Future<void> reload() async {
      ref.invalidate(fairProjectsProvider(fairId));
      ref.invalidate(myEvaluationsProvider(fairId));
      ref.invalidate(juryProgressProvider(fairId));
      await ref.read(fairProjectsProvider(fairId).future);
    }

    return Scaffold(
      // Progreso, votar y resultados viven ahora en la barra de accesos del
      // cuerpo, con etiqueta visible, en lugar de tres íconos sin texto.
      appBar: OrganizationPanelAppBar(
        branding: branding,
        section: 'Proyectos',
        onBack: () => context.pop(),
      ),
      body: RefreshIndicator(
        onRefresh: reload,
        child: _bodyFor(fairId, projects, reload),
      ),
    );
  }
}

Widget _bodyFor(
  String fairId,
  AsyncValue<List<FairProjectModel>> projects,
  Future<void> Function() onRetry,
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
      return FairProjectsBody(fairId: fairId, projects: value);
    default:
      return const AppLoader();
  }
}