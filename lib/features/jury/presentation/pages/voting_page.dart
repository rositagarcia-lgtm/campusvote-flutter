import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../providers/jury_providers.dart';
import '../providers/jury_state.dart';
import '../widgets/voting_widgets.dart';
import '../../data/models/jury_models.dart';

/// `/jury/fair/:fairId/vote` — voto anónimo, uno por jurado.
///
/// Reglas: se bloquea si `isOpen == false` o `hasVoted == true`, y el botón
/// queda deshabilitado desde el primer tap hasta que el POST responda (el
/// backend rechaza el segundo voto con 409).
class VotingPage extends ConsumerWidget {
  const VotingPage({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(votingFormProvider(fairId));
    final controller = ref.read(votingFormProvider(fairId).notifier);
    final assignments = ref.watch(juryDashboardProvider).asData?.value ??
        const <FairAssignmentModel>[];
    String? fairName;
    for (final assignment in assignments) {
      if (assignment.fairId == fairId) {
        fairName = assignment.name;
        break;
      }
    }

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Votación'),
      body: state.loading
          ? const AppLoader()
          : !state.statusIsLoaded
              ? AppErrorView(
                  message:
                      state.errorMessage ?? 'No se pudo cargar la votación',
                  onRetry: controller.load,
                )
              : _VotingBody(
                  fairName: fairName,
                  state: state,
                  controller: controller,
                ),
    );
  }
}

extension on VotingFormState {
  bool get statusIsLoaded => status != null;
}

class _VotingBody extends StatelessWidget {
  const _VotingBody({
    required this.fairName,
    required this.state,
    required this.controller,
  });

  final String? fairName;
  final VotingFormState state;
  final VotingFormController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = state.status!;

    if (state.receipt != null) {
      return VoteReceiptView(receipt: state.receipt!);
    }
    if (state.hasVoted) {
      return VoteParticipationView(status: state.status!);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Text(
                fairName ?? 'Votación oficial de la feria',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Selecciona un proyecto aprobado. Puedes emitir un solo voto; '
                'el servidor valida la asignación y el período de votación. '
                'Tu selección no se guarda en este dispositivo.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.l),
              if (!status.isOpen)
                const NoticeBanner(
                  message:
                      'La votación está cerrada: la feria no está abierta.',
                  tone: AppTone.warning,
                  icon: Icons.lock_rounded,
                ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.m),
                NoticeBanner(
                  message: state.errorMessage!,
                  tone: AppTone.danger,
                  liveRegion: true,
                ),
              ],
              if (state.requiresStatusRefresh) ...[
                const SizedBox(height: AppSpacing.m),
                const NoticeBanner(
                  message:
                      'No se pudo confirmar la respuesta del servidor. Consulta el estado antes de volver a votar.',
                  tone: AppTone.warning,
                  icon: Icons.cloud_sync_outlined,
                  liveRegion: true,
                ),
                const SizedBox(height: AppSpacing.s),
                AppButton.outlined(
                  label: 'Consultar estado de votación',
                  icon: Icons.refresh_rounded,
                  onPressed: state.loading ? null : controller.refreshStatus,
                  isLoading: state.loading,
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              if (state.projects.isEmpty)
                AppCard(
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          color: theme.colorScheme.primary),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        'No hay proyectos disponibles',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'No encontramos proyectos aprobados para tu asignación. Puedes volver a consultar más tarde.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  state.selectedProjectId == null
                      ? 'Elige un proyecto'
                      : 'Proyecto seleccionado',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.s),
                for (final project in state.projects) ...[
                  VotingProjectOption(
                    project: project,
                    selected: state.selectedProjectId == project.id,
                    enabled: state.canVote,
                    onTap: () => controller.select(project.id),
                  ),
                  const SizedBox(height: AppSpacing.s),
                ],
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: AppButton(
              label: state.selectedProjectId == null
                  ? 'Selecciona un proyecto para continuar'
                  : 'Revisar y confirmar voto',
              icon: Icons.how_to_vote_rounded,
              // `canVote` ya incluye `!submitting`: el botón no se rearma
              // hasta que el POST termine.
              onPressed: state.canVote && state.selectedProjectId != null
                  ? () => _confirmVote(context, state, controller)
                  : null,
              isLoading: state.submitting,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmVote(
    BuildContext context,
    VotingFormState state,
    VotingFormController controller,
  ) async {
    final project = state.projects.where(
      (item) => item.id == state.selectedProjectId,
    );
    if (project.isEmpty) return;
    final selected = project.first;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: const Text('Confirma tu voto oficial'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Revisa la selección. Después de enviarlo, no podrás cambiar ni repetir tu voto.',
              ),
              if (fairName != null) ...[
                const SizedBox(height: AppSpacing.l),
                Text('Feria',
                    style: Theme.of(dialogContext).textTheme.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(fairName!, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: AppSpacing.l),
              Text('Proyecto',
                  style: Theme.of(dialogContext).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                selected.name,
                style: Theme.of(dialogContext)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (selected.description.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s),
                Text(
                  selected.description,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (selected.categoryName != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(selected.categoryName!),
              ],
              const SizedBox(height: AppSpacing.m),
              const Text(
                  'El comprobante confirma tu participación; no revela tu selección.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Volver'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.lock_outline_rounded),
            label: const Text('Confirmar voto'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.submit();
  }
}
