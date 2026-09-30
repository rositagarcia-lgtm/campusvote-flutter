import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/entities/fair_project.dart';
import '../state/fair_projects_controller.dart';
import '../state/my_assigned_fairs_controller.dart';

/// Lista de proyectos APPROVED de una feria (vista del JURY).
///
/// A cada proyecto se le indica si la rúbrica ya fue finalizada.
/// Al final, un botón flotante lleva al panel de VOTACIÓN.
class FairProjectsPage extends ConsumerStatefulWidget {
  final String fairId;
  const FairProjectsPage({super.key, required this.fairId});

  @override
  ConsumerState<FairProjectsPage> createState() => _FairProjectsPageState();
}

class _FairProjectsPageState extends ConsumerState<FairProjectsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fairProjectsControllerProvider(widget.fairId).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fairProjectsControllerProvider(widget.fairId));
    final fairState = ref.watch(myAssignedFairsControllerProvider);
    final fairName = fairState.items
        .where((f) => f.fairId == widget.fairId)
        .map((f) => f.name)
        .firstOrNull;

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: fairName ?? 'Proyectos',
      ),
      floatingActionButton: state.projects.isEmpty
          ? null
          : _VotingButton(
              enabled: state.allRubricsFinalized,
              fairId: widget.fairId,
            ),
      body: _Body(
        state: state,
        fairName: fairName,
        fairId: widget.fairId,
        onRefresh: () =>
            ref.read(fairProjectsControllerProvider(widget.fairId).notifier).load(),
      ),
    );
  }
}

class _VotingButton extends StatelessWidget {
  final bool enabled;
  final String fairId;
  const _VotingButton({required this.enabled, required this.fairId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: enabled
          ? () => context.go('/juries/fairs/$fairId/voting')
          : null,
      icon: const Icon(Icons.how_to_vote_rounded),
      label: Text(enabled ? 'Ir a votación' : 'Finaliza todas las rúbricas'),
      backgroundColor:
          enabled ? Theme.of(context).colorScheme.primary : AppColors.background,
      foregroundColor:
          enabled ? Theme.of(context).colorScheme.onPrimary : AppColors.inkFaint,
    );
  }
}

class _Body extends ConsumerWidget {
  final FairProjectsState state;
  final String? fairName;
  final String fairId;
  final Future<void> Function() onRefresh;

  const _Body({
    required this.state,
    required this.fairName,
    required this.fairId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.loading && state.projects.isEmpty) {
      return const AppLoader();
    }
    if (state.errorMessage != null && state.projects.isEmpty) {
      return AppErrorView(message: state.errorMessage!, onRetry: onRefresh);
    }
    if (state.projects.isEmpty) {
      return const AppEmptyView(
        icon: Icons.folder_off_rounded,
        message: 'Esta feria aún no tiene proyectos APPROVED.',
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.xxl + AppSpacing.xl,
        ),
        children: [
          _Header(state: state, fairName: fairName),
          const SizedBox(height: AppSpacing.l),
          for (final p in state.projects)
            _ProjectTile(
              fairId: fairId,
              project: p,
              submitted: state.submitted[p.id] ?? false,
              finalized: state.finalizedProjectIds.contains(p.id),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final FairProjectsState state;
  final String? fairName;
  const _Header({required this.state, required this.fairName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = state.completedCount;
    final total = state.projects.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: context.brandPrimarySoft,
        borderRadius: AppRadii.rMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proyectos asignados',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s),
          ClipRRect(
            borderRadius: AppRadii.rSmall,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.background,
              color: context.brandPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '$completed / $total rúbricas finalizadas',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final String fairId;
  final FairProject project;
  final bool submitted;
  final bool finalized;

  const _ProjectTile({
    required this.fairId,
    required this.project,
    required this.submitted,
    required this.finalized,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusLabel, statusBg, statusFg) = finalized
        ? ('Rúbrica finalizada', AppColors.successSoft, AppColors.success)
        : submitted
            ? ('Borrador guardado', AppColors.warningSoft, AppColors.warning)
            : ('Pendiente', AppColors.background, AppColors.inkFaint);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.rMedium,
        child: InkWell(
          borderRadius: AppRadii.rMedium,
          onTap: () => context.go(
            '/juries/fairs/$fairId/projects/${project.id}/rubric',
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: project.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            project.logoUrl!,
                            fit: BoxFit.cover,
errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported_rounded,
                              color: AppColors.inkFaint,
                            ),
                          )
                        )
                        : Icon(Icons.science_rounded, color: context.brandPrimary),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: AppRadii.rSmall,
                            ),
                            child: Text(
                              statusLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: statusFg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (project.categoryName != null) ...[
                            const SizedBox(width: AppSpacing.s),
                            Flexible(
                              child: Text(
                                project.categoryName!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.inkFaint,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  finalized
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: finalized
                      ? AppColors.success
                      : AppColors.inkFaint,
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
