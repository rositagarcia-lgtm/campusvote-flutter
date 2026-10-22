import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../fair_results/presentation/published_results_section.dart';
import 'package:go_router/go_router.dart';

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
import '../../../auth/domain/entities/auth_role.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_dashboard_progress.dart';
import '../providers/jury_providers.dart';
import '../widgets/jury_dashboard_overview.dart';
import '../../../../features/auth/presentation/widgets/account_avatar_button.dart';
import '../widgets/jury_fair_card.dart';

/// `/jury` — dashboard de ferias asignadas (`GET /fairs/my-assignments`).
class JuryDashboardPage extends ConsumerWidget {
  const JuryDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fairs = ref.watch(juryDashboardProvider);
    final branding = ref.watch(brandingControllerProvider);
    // El docente es jurado solo en algunas ferias: aquí está en "modo jurado"
    // y siempre puede volver a su panel docente.
    final isTeacher = ref.watch(
      authControllerProvider.select((s) => s.user?.role == AuthRole.teacher),
    );

    return Scaffold(
      appBar: OrganizationPanelAppBar(
        branding: branding,
        section: isTeacher ? 'Modo jurado' : 'Panel del jurado',
        // Avisos y cuenta ya son pestañas de la barra inferior; aquí solo
        // queda la acción propia de esta vista.
        actions: [
          if (isTeacher)
            IconButton(
              tooltip: 'Volver a mi panel docente',
              icon: const Icon(PhosphorIconsRegular.house),
              onPressed: () => context.go('/teacher'),
            ),
          const NotificationsBell(),
          const AccountAvatarButton(),
        ],
      ),
      body: RefreshIndicator.adaptive(
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
    if (fair.canOpen) ref.invalidate(juryProgressProvider(fair.fairId));
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
    // En curso = día de feria o vista previa; van primero porque son las
    // que piden algo al jurado hoy.
    bool active(FairAssignmentModel f) =>
        f.phase == JuryPhase.live || f.phase == JuryPhase.preview;
    final open = fairs.where(active).toList(growable: false)
      ..sort((a, b) => a.phase.index.compareTo(b.phase.index) * -1);
    final others = fairs.where((f) => !active(f)).toList(growable: false);
    return PageScrollBody(
      // Siempre desplazable para permitir actualizar con poco contenido.
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppMotion.reveal(
            0,
            JuryDashboardOverview(
              openCount: open.length,
              assignedCount: fairs.length,
              progress: progress,
              firstName: ref.watch(
                  authControllerProvider.select((s) => s.user?.firstName)),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          if (open.isNotEmpty) ...[
            SectionHeader(
              label: 'TU AGENDA',
              title: 'Ferias en curso',
              count: open.length,
            ),
            ..._cards(open),
            const SizedBox(height: AppSpacing.l),
            const PublishedResultsSection(),
          ] else ...[
            const PublishedResultsSection(),
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
