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
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_panel_intro.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/organization_panel_app_bar.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../settings/presentation/settings_copy.dart';
import '../../../student_projects/presentation/widgets/student_projects_shortcut.dart';
import '../state/teaching_list_controller.dart';
import '../widgets/assignment_card.dart';

/// Inicio del estudiante: asignaciones docentes entregadas por el backend.
class TeachingHomePage extends ConsumerWidget {
  const TeachingHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teachingListControllerProvider);
    final controller = ref.read(teachingListControllerProvider.notifier);
    final text = SettingsCopy.of(context);

    return Scaffold(
      // Misma barra que el panel del jurado: logo y nombre de la
      // organización arriba; el cierre de sesión vive en "Sobre mí".
      appBar: OrganizationPanelAppBar(
        branding: ref.watch(brandingControllerProvider),
        section: text.t('Evaluación docente'),
        actions: [
          IconButton(
            tooltip: text.t('Actualizar asignaciones'),
            icon: const Icon(PhosphorIconsRegular.arrowClockwise),
            onPressed: state.loading ? null : controller.refresh,
          ),
        ],
      ),
      body: _TeachingAssignmentsBody(
        state: state,
        onRefresh: controller.refresh,
      ),
      bottomNavigationBar: const AppBottomNav(current: AppNavDestination.panel),
    );
  }
}

class _TeachingAssignmentsBody extends ConsumerWidget {
  const _TeachingAssignmentsBody({
    required this.state,
    required this.onRefresh,
  });

  final TeachingListState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.loading && state.items.isEmpty) return const AppLoader();
    if (state.errorMessage != null && state.items.isEmpty) {
      return AppErrorView(
        message: state.errorMessage!,
        onRetry: () => onRefresh(),
      );
    }
    if (state.isEmpty) {
      return AppEmptyView(
        icon: PhosphorIconsRegular.graduationCap,
        title: 'Sin asignaciones docentes',
        message: 'Cuando haya docentes asignados a tu carrera y ciclo, '
            'aparecerán aquí para que puedas evaluarlos.',
        actionLabel: 'Actualizar lista',
        onAction: () => onRefresh(),
      );
    }

    final pending = state.pending.where((item) => item.isActive).toList();
    final unavailable = state.pending.where((item) => !item.isActive).toList();
    final completed = state.done;
    final branding = ref.watch(brandingControllerProvider);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppMotion.reveal(
                    0,
                    AppPanelIntro(
                      // La barra superior ya muestra logo y nombre.
                      showOrganizationHeader: false,
                      organizationName: branding.name,
                      organizationLogoUrl: branding.logoUrl,
                      title: 'Tus docentes',
                      subtitle:
                          'Consulta tus asignaciones y califica a cada docente.',
                      primaryValue: pending.length,
                      primaryLabel: 'pendientes',
                      secondaryValue: completed.length,
                      secondaryLabel: 'completadas',
                    ),
                  ),
                  const StudentProjectsShortcut(),
                  if (state.loading) ...[
                    const SizedBox(height: AppSpacing.m),
                    const LinearProgressIndicator(),
                  ],
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.m),
                    NoticeBanner(
                      message: state.errorMessage!,
                      tone: AppTone.danger,
                      liveRegion: true,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  if (pending.isNotEmpty) ...[
                    SectionHeader(
                      label: 'SIGUIENTE ACCIÓN',
                      title: 'Por evaluar',
                      subtitle: 'Elige una asignación pendiente para comenzar.',
                      count: pending.length,
                    ),
                    for (var i = 0; i < pending.length; i++)
                      AppMotion.reveal(
                        i + 1,
                        AssignmentCard(assignment: pending[i]),
                      ),
                  ],
                  if (unavailable.isNotEmpty) ...[
                    if (pending.isNotEmpty)
                      const SizedBox(height: AppSpacing.l),
                    SectionHeader(
                      label: 'ASIGNACIONES',
                      title: 'No disponibles',
                      subtitle: 'Estas asignaciones no están activas.',
                      count: unavailable.length,
                    ),
                    for (final assignment in unavailable)
                      AssignmentCard(assignment: assignment),
                  ],
                  if (completed.isNotEmpty) ...[
                    if (pending.isNotEmpty || unavailable.isNotEmpty)
                      const SizedBox(height: AppSpacing.l),
                    SectionHeader(
                      label: 'SEGUIMIENTO',
                      title: 'Completadas',
                      subtitle: 'El servidor confirma estas evaluaciones.',
                      count: completed.length,
                    ),
                    for (final assignment in completed)
                      AssignmentCard(assignment: assignment),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
