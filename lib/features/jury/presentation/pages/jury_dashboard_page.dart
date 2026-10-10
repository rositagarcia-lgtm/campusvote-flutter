import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/branding/branding_controller.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../notifications/presentation/widgets/notifications_bell.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/organization_panel_app_bar.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_dashboard_progress.dart';
import '../providers/jury_providers.dart';
import '../widgets/jury_dashboard_overview.dart';
import '../widgets/jury_fair_card.dart';

/// `/jury` — dashboard de ferias asignadas (`GET /fairs/my-assignments`).
class JuryDashboardPage extends ConsumerWidget {
  const JuryDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fairs = ref.watch(juryDashboardProvider);
    final branding = ref.watch(brandingControllerProvider);

    return Scaffold(
      appBar: OrganizationPanelAppBar(
        branding: branding,
        section: 'Panel del jurado',
        // Avisos y cuenta ya son pestañas de la barra inferior; aquí solo
        // queda la acción propia de esta vista.
        actions: [
          const NotificationsBell(),
          IconButton(
            tooltip: 'Actualizar ferias',
            icon: const Icon(PhosphorIconsRegular.arrowClockwise),
            onPressed: () => _reload(ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _reload(ref),
        child: _bodyFor(context, ref, fairs),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppNavDestination.panel),
    );
  }
}

Future<void> _reload(WidgetRef ref) async {
  final current = ref.read(juryDashboardProvider).valueOrNull;
  for (final fair in current ?? const <FairAssignmentModel>[]) {
    if (fair.isOpen) ref.invalidate(juryProgressProvider(fair.fairId));
  }
  await ref.read(juryDashboardProvider.notifier).reload();
}

/// `AsyncValue` no es una jerarquía sellada, así que el caso por defecto se
/// trata explícitamente en vez de usar un switch exhaustivo.
Widget _bodyFor(
  BuildContext context,
  WidgetRef ref,
  AsyncValue<List<FairAssignmentModel>> fairs,
) {
  switch (fairs) {
    case AsyncLoading():
      return const AppLoader();
    case AsyncError(:final error):
      return AppErrorView(
        message: describeJuryError(error),
        onRetry: () => ref.read(juryDashboardProvider.notifier).reload(),
      );
    case AsyncData(:final value):
      if (value.isEmpty) {
        return const AppEmptyView(
          icon: PhosphorIconsRegular.calendarX,
          overline: 'ASIGNACIONES',
          title: 'Aún no tienes ferias asignadas',
          message:
              'Cuando la organización te asigne una feria, aparecerá aquí. Desliza hacia abajo para actualizar.',
        );
      }
      return _FairsList(fairs: value);
    default:
      return const AppLoader();
  }
}

class _FairsList extends ConsumerWidget {
  const _FairsList({required this.fairs});

  final List<FairAssignmentModel> fairs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(juryDashboardProgressProvider);
    final open = fairs.where((f) => f.isOpen).toList(growable: false);
    final others = fairs.where((f) => !f.isOpen).toList(growable: false);
    return PageScrollBody(
      // Siempre desplazable para permitir actualizar con poco contenido.
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppMotion.reveal(
            0,
            JuryDashboardOverview(
              openCount: open.length,
              assignedCount: fairs.length,
              progress: progress,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          if (open.isNotEmpty) ...[
            SectionHeader(
              label: 'ACCESO DISPONIBLE',
              title: 'Ferias abiertas',
              count: open.length,
            ),
            ..._cards(open),
          ] else ...[
            const NoticeBanner(
              tone: AppTone.info,
              icon: PhosphorIconsRegular.calendarX,
              message:
                  'Por ahora no tienes ferias abiertas. Revisa tus otras asignaciones m\u00e1s abajo.',
            ),
          ],
          if (others.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              label: 'ASIGNACIONES',
              title: 'Otras asignaciones',
              count: others.length,
            ),
            ..._cards(others, from: open.length + 1),
          ],
        ],
      ),
    );
  }

  List<Widget> _cards(List<FairAssignmentModel> list, {int from = 1}) {
    return [
      for (var i = 0; i < list.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.m),
          child: AppMotion.reveal(from + i, FairCard(fair: list[i])),
        ),
    ];
  }
}
