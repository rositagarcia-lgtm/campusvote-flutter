import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../domain/entities/fair_project.dart';
import '../state/fair_projects_controller.dart';
import '../state/voting_controller.dart';

/// Panel de VOTACIÓN del JURY.
///
/// - Carga el status (has_voted).
/// - Lista los proyectos APPROVED de la feria (para que el JURY vea a quién
///   puede votar).
/// - El JURY selecciona UNO y confirma. El backend registra el voto de forma
///   anónima.
/// - Tras votar: muestra estado "Ya votaste" y bloquea una segunda votación.
class VotingPage extends ConsumerStatefulWidget {
  final String fairId;
  const VotingPage({super.key, required this.fairId});

  @override
  ConsumerState<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends ConsumerState<VotingPage> {
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(votingPanelControllerProvider(widget.fairId).notifier).load();
      ref
          .read(fairProjectsControllerProvider(widget.fairId).notifier)
          .load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(votingPanelControllerProvider(widget.fairId));
    final fairState =
        ref.watch(fairProjectsControllerProvider(widget.fairId));

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Votación',
      ),
      body: _Body(
        state: state,
        projects: fairState.projects,
        fairId: widget.fairId,
        selectedProjectId: _selectedProjectId,
        onSelect: (id) => setState(() => _selectedProjectId = id),
        onConfirm: _confirmVote,
      ),
    );
  }

  Future<void> _confirmVote(String projectId) async {
    final ctrl = ref.read(votingPanelControllerProvider(widget.fairId).notifier);
    final ok = await ctrl.castVote(projectId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voto registrado correctamente')),
      );
      context.go('/juries/fairs/${widget.fairId}/voting/success');
    } else {
      final state = ref.read(votingPanelControllerProvider(widget.fairId));
      final err = state.errorMessage ?? 'No se pudo registrar el voto';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
    }
  }
}

class _Body extends ConsumerWidget {
  final VotingPanelState state;
  final List<FairProject> projects;
  final String fairId;
  final String? selectedProjectId;
  final ValueChanged<String?> onSelect;
  final Future<void> Function(String projectId) onConfirm;

  const _Body({
    required this.state,
    required this.projects,
    required this.fairId,
    required this.selectedProjectId,
    required this.onSelect,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.loading) return const AppLoader();
    if (state.errorMessage != null && state.status == null) {
      return AppErrorView(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(votingPanelControllerProvider(fairId).notifier).load(),
      );
    }

    if (state.hasVoted) {
      return _AlreadyVoted(fairStatus: state.status?.fairStatus ?? 'OPEN');
    }

    if (projects.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text('No hay proyectos disponibles para votar.'),
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                const                 AppSectionTitle(title: 'Selecciona UN proyecto'),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: AppRadii.rMedium,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.primary),
                      SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          'Tu voto es la decisión FINAL del jurado y es '
                          'ANÓNIMO. No podrás cambiarlo después.',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                for (final p in projects)
                  _VoteProjectTile(
                    project: p,
                    selected: selectedProjectId == p.id,
                    onTap: () => onSelect(p.id),
                  ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
          _ConfirmBar(
            enabled: selectedProjectId != null,
            casting: state.casting,
            onConfirm: () {
              if (selectedProjectId == null) return;
              onConfirm(selectedProjectId!);
            },
          ),
        ],
      ),
    );
  }
}

class _AlreadyVoted extends StatelessWidget {
  final String fairStatus;
  const _AlreadyVoted({required this.fairStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.successSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 56, color: AppColors.success),
            ),
            const SizedBox(height: AppSpacing.l),
            Text('Ya votaste', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Tu voto fue registrado de forma anónima. '
              'El sistema no permite una segunda votación.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteProjectTile extends StatelessWidget {
  final FairProject project;
  final bool selected;
  final VoidCallback onTap;

  const _VoteProjectTile({
    required this.project,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Material(
        color: selected ? AppColors.primarySoft : theme.colorScheme.surface,
        borderRadius: AppRadii.rMedium,
        child: InkWell(
          borderRadius: AppRadii.rMedium,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.primary : AppColors.inkFaint,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      if (project.categoryName != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          project.categoryName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.inkFaint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  final bool enabled;
  final bool casting;
  final VoidCallback onConfirm;

  const _ConfirmBar({
    required this.enabled,
    required this.casting,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: AppButton(
          label: casting
              ? 'Registrando voto…'
              : (enabled ? 'Confirmar voto' : 'Selecciona un proyecto'),
          icon: Icons.how_to_vote_rounded,
          isLoading: casting,
          onPressed: enabled && !casting ? onConfirm : null,
        ),
      ),
    );
  }
}
