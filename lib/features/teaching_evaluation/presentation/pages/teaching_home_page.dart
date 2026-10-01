import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/panel_hero.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../state/teaching_list_controller.dart';

/// Inicio del ESTUDIANTE: sus asignaciones docentes del periodo.
///
/// - "Por evaluar": asignaciones activas sin evaluación.
/// - "Evaluadas": ya respondidas (no se pueden repetir; el backend lo impide).
class TeachingHomePage extends ConsumerWidget {
  const TeachingHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teachingListControllerProvider);
    final ctrl = ref.read(teachingListControllerProvider.notifier);

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Mis docentes',
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.refresh,
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
      body: _Body(state: state, onRefresh: ctrl.refresh),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
    );
  }
}

class _Body extends ConsumerWidget {
  final TeachingListState state;
  final Future<void> Function() onRefresh;

  const _Body({required this.state, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.loading && state.items.isEmpty) return const AppLoader();
    if (state.errorMessage != null && state.items.isEmpty) {
      return AppErrorView(message: state.errorMessage!, onRetry: onRefresh);
    }
    if (state.isEmpty) {
      return const AppEmptyView(
        icon: Icons.school_outlined,
        message: 'Aún no tienes docentes asignados en este periodo. Cuando tu '
            'organización asigne docentes a tu carrera y ciclo, aparecerán aquí.',
      );
    }

    final pending = state.pending.where((a) => a.isActive).toList();
    final unavailable = state.pending.where((a) => !a.isActive).toList();
    final done = state.done;
    final branding = ref.watch(brandingControllerProvider);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          PanelHero(
            title: 'Panel del estudiante',
            subtitle: 'Evalúa el desempeño de tus docentes de forma anónima',
            icon: Icons.school_rounded,
            badge: pending.isNotEmpty
                ? '${pending.length} docente${pending.length == 1 ? '' : 's'} por evaluar'
                : 'Todo evaluado este periodo',
            organizationLogoUrl: branding.logoUrl,
            organizationName: branding.name,
          ),
          const SizedBox(height: AppSpacing.l),
          if (pending.isNotEmpty) ...[
            const _SectionHeader(
              title: 'Por evaluar',
              subtitle: 'Tu opinión suma a la mejora de la enseñanza',
            ),
            for (final a in pending) _AssignmentCard(assignment: a),
          ],
          if (unavailable.isNotEmpty) ...[
            if (pending.isNotEmpty) const SizedBox(height: AppSpacing.l),
            const _SectionHeader(
              title: 'No disponibles',
              subtitle: 'Estas asignaciones no están activas en este periodo.',
            ),
            for (final a in unavailable) _AssignmentCard(assignment: a),
          ],
          if (done.isNotEmpty) ...[
            if (pending.isNotEmpty) const SizedBox(height: AppSpacing.l),
            const _SectionHeader(
              title: 'Evaluados',
              subtitle: 'Gracias por tu participación',
            ),
            for (final a in done) _AssignmentCard(assignment: a),
          ],
          const SizedBox(height: AppSpacing.xxl),
          const _AnonymityNote(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
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
  final TeachingAssignment assignment;
  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = assignment.isActive && !assignment.evaluated;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: AppCard(
        padding: EdgeInsets.zero,
        bordered: true,
        elevated: enabled,
        child: InkWell(
          borderRadius: AppRadii.rMedium,
          onTap: enabled
              ? () => context.go('/teaching/evaluate/${assignment.id}')
              : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: enabled
                        ? context.brandPrimarySoft
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: enabled ? context.brandPrimary : AppColors.inkFaint,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.courseName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${assignment.courseCode} · Ciclo ${assignment.cycle}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: AppDimensions.iconSmall,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              assignment.teacherFullName,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                assignment.evaluated
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                      )
                    : !assignment.isActive
                        ? Icon(
                            Icons.lock_outline_rounded,
                            color: theme.textTheme.bodySmall?.color,
                          )
                        : Icon(
                            Icons.chevron_right_rounded,
                            color: theme.textTheme.bodySmall?.color,
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnonymityNote extends StatelessWidget {
  const _AnonymityNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: context.brandPrimarySoft,
        borderRadius: AppRadii.rMedium,
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: context.brandPrimary),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Las evaluaciones son anónimas. Toma las decisiones finales '
              'se basan en el promedio de todas las respuestas.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
