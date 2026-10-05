import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/panel_hero.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../state/teaching_list_controller.dart';

/// Inicio del estudiante: asignaciones docentes entregadas por el backend.
class TeachingHomePage extends ConsumerWidget {
  const TeachingHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teachingListControllerProvider);
    final controller = ref.read(teachingListControllerProvider.notifier);

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Evaluación docente',
        actions: [
          IconButton(
            tooltip: 'Actualizar asignaciones',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.loading ? null : controller.refresh,
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/splash');
            },
          ),
        ],
      ),
      body: _TeachingAssignmentsBody(
        state: state,
        onRefresh: controller.refresh,
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
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
        icon: Icons.school_outlined,
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
                  PanelHero(
                    title: 'Tus docentes',
                    subtitle:
                        'Consulta tus asignaciones y califica a cada docente.',
                    icon: Icons.school_rounded,
                    badge: pending.isNotEmpty
                        ? '${pending.length} pendiente${pending.length == 1 ? '' : 's'}'
                        : completed.isNotEmpty
                            ? 'Sin pendientes'
                            : 'Sin evaluaciones pendientes',
                    organizationLogoUrl: branding.logoUrl,
                    organizationName: branding.name,
                  ),
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
                    _SectionHeader(
                      title: 'Por evaluar',
                      subtitle: 'Elige una asignación pendiente para comenzar.',
                      count: pending.length,
                    ),
                    for (final assignment in pending)
                      _AssignmentCard(assignment: assignment),
                  ],
                  if (unavailable.isNotEmpty) ...[
                    if (pending.isNotEmpty)
                      const SizedBox(height: AppSpacing.l),
                    _SectionHeader(
                      title: 'No disponibles',
                      subtitle: 'Estas asignaciones no están activas.',
                      count: unavailable.length,
                    ),
                    for (final assignment in unavailable)
                      _AssignmentCard(assignment: assignment),
                  ],
                  if (completed.isNotEmpty) ...[
                    if (pending.isNotEmpty || unavailable.isNotEmpty)
                      const SizedBox(height: AppSpacing.l),
                    _SectionHeader(
                      title: 'Completadas',
                      subtitle: 'El servidor confirma estas evaluaciones.',
                      count: completed.length,
                    ),
                    for (final assignment in completed)
                      _AssignmentCard(assignment: assignment),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  final String title;
  final String subtitle;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              '$title · $count',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment});

  final TeachingAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = assignment.isActive && !assignment.evaluated;
    final (statusLabel, tone, statusIcon) = assignment.evaluated
        ? ('Completada', AppTone.success, Icons.check_circle_outline_rounded)
        : assignment.isActive
            ? ('Por evaluar', AppTone.primary, Icons.rate_review_outlined)
            : ('No disponible', AppTone.neutral, Icons.lock_outline_rounded);
    final courseName = assignment.courseName.trim().isEmpty
        ? 'Curso sin nombre'
        : assignment.courseName;
    final teacherName = assignment.teacherFullName.trim().isEmpty
        ? 'Nombre del docente no disponible'
        : assignment.teacherFullName;
    final courseMetadata = [
      if (assignment.courseCode.trim().isNotEmpty) assignment.courseCode,
      if (assignment.cycle > 0) 'Ciclo ${assignment.cycle}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: AppRadii.rLarge,
          onTap: enabled
              ? () => context.go('/teaching/evaluate/${assignment.id}')
              : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: enabled
                            ? context.brandPrimarySoft
                            : AppColors.background,
                        borderRadius: AppRadii.rMedium,
                      ),
                      child: Icon(
                        Icons.menu_book_outlined,
                        color:
                            enabled ? context.brandPrimary : AppColors.inkFaint,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Text(
                        courseName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (enabled) ...[
                      const SizedBox(width: AppSpacing.s),
                      Icon(Icons.chevron_right_rounded,
                          color: theme.colorScheme.primary),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  courseMetadata.isEmpty
                      ? 'Información del curso no disponible'
                      : courseMetadata,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.s),
                Semantics(
                  label: 'Docente: $teacherName',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: AppDimensions.iconSmall,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          teacherName,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                StatusChip(label: statusLabel, tone: tone, icon: statusIcon),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
