import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/entities/fair_assignment.dart';
import '../state/my_assigned_fairs_controller.dart';

/// Lista de ferias asignadas al JURY autenticado.
///
/// Punto de entrada del flujo JURY:
///  1) Elige una feria abierta
///  2) → Lista de proyectos a evaluar
///  3) → Rúbrica de cada proyecto
///  4) → Votación final
class MyFairsPage extends ConsumerWidget {
  const MyFairsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myAssignedFairsControllerProvider);
    final ctrl =
        ref.read(myAssignedFairsControllerProvider.notifier);

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Mis ferias asignadas',
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              // El botón de logout se gestiona en el perfil; dejamos un botón
              // de refresh aquí para simplificar la pantalla.
              await ctrl.refresh();
            },
          ),
        ],
      ),
      body: _Body(state: state, onRefresh: ctrl.refresh),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state, required this.onRefresh});

  final MyAssignedFairsState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.loading && state.items.isEmpty) {
      return const AppLoader();
    }
    if (state.errorMessage != null && state.items.isEmpty) {
      return AppErrorView(message: state.errorMessage!, onRetry: onRefresh);
    }
    if (state.items.isEmpty) {
      return const AppEmptyView(
        icon: Icons.event_busy_rounded,
        message: 'Sin ferias asignadas. Aún no tienes ferias asignadas. Vuelve más tarde.',
      );
    }

    final openFairs =
        state.items.where((f) => f.isOpen).toList(growable: false);
    final others =
        state.items.where((f) => !f.isOpen).toList(growable: false);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          if (openFairs.isNotEmpty) ...[
            const _SectionLabel('Abiertas · Evalúa y vota'),
            for (final f in openFairs) _FairTile(fair: f),
          ],
          if (others.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            const _SectionLabel('Otras ferias'),
            for (final f in others) _FairTile(fair: f),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _FairTile extends StatelessWidget {
  final FairAssignment fair;
  const _FairTile({required this.fair});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = fair.isOpen;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.rMedium,
        child: InkWell(
          borderRadius: AppRadii.rMedium,
          onTap: enabled
              ? () => context.go('/juries/fairs/${fair.fairId}/projects')
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
                        ? AppColors.primarySoft
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.event_rounded,
                    color: enabled ? AppColors.primary : AppColors.inkFaint,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fair.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (fair.description.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          fair.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s),
                      _StatusChip(status: fair.status),
                    ],
                  ),
                ),
                if (enabled)
                  const Icon(Icons.chevron_right_rounded, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final FairAssignmentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      FairAssignmentStatus.open => (
        'Abierta',
        AppColors.successSoft,
        AppColors.success,
      ),
      FairAssignmentStatus.closed => (
        'Cerrada',
        AppColors.background,
        AppColors.inkFaint,
      ),
      FairAssignmentStatus.draft => (
        'En preparación',
        AppColors.warningSoft,
        AppColors.warning,
      ),
      FairAssignmentStatus.unknown => (
        'Sin estado',
        AppColors.background,
        AppColors.inkFaint,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.rSmall,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
