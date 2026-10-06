// voting/widgets/voting_body.dart

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_notice.dart';
import '../../../../../core/widgets/app_status_chip.dart';
import '../../providers/forms/jury_voting_provider.dart';
import '../../providers/jury_state.dart';
import '../../widgets/voting_widgets.dart';
import 'vote_confirm_dialog.dart';

/// Cuerpo de la votación con el estado ya cargado.
///
/// Tres salidas posibles, todas reales: comprobante (acaba de votar), estado de
/// participación (ya votó antes) o el formulario de selección.
class VotingBody extends StatelessWidget {
  const VotingBody({
    super.key,
    required this.fairName,
    required this.state,
    required this.controller,
    required this.onSubmitted,
  });

  final String? fairName;
  final VotingFormState state;
  final VotingFormController controller;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = state.status!;

    if (state.receipt != null) {
      return VoteReceiptView(receipt: state.receipt!);
    }
    if (state.hasVoted) {
      return VoteParticipationView(status: status);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Text(
                'VOTACIÓN OFICIAL',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                fairName ?? 'Votación oficial de la feria',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Elige un proyecto. Podrás revisar tu selección antes de emitir '
                'tu único voto.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
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
                      'No se pudo confirmar la respuesta del servidor. Consulta '
                      'el estado antes de volver a votar.',
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
              _projects(context, theme),
            ],
          ),
        ),
        _submitBar(context),
      ],
    );
  }

  /// Lista de proyectos votables o el estado vacío real de la asignación.
  Widget _projects(BuildContext context, ThemeData theme) {
    if (state.projects.isEmpty) {
      return AppCard(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.s),
            Text(
              'No hay proyectos disponibles',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'No encontramos proyectos aprobados para tu asignación. Puedes '
              'volver a consultar más tarde.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.selectedProjectId == null
              ? 'Elige un proyecto'
              : 'Proyecto seleccionado',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
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
    );
  }

  /// Acción fija al pie. `canVote` ya incluye `!submitting`: el botón no se
  /// rearma hasta que el POST termine.
  Widget _submitBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: AppButton(
          label: state.selectedProjectId == null
              ? 'Selecciona un proyecto para continuar'
              : 'Revisar y confirmar voto',
          icon: Icons.how_to_vote_rounded,
          onPressed: state.canVote && state.selectedProjectId != null
              ? () => _confirmVote(context)
              : null,
          isLoading: state.submitting,
        ),
      ),
    );
  }

  Future<void> _confirmVote(BuildContext context) async {
    final matches =
        state.projects.where((item) => item.id == state.selectedProjectId);
    if (matches.isEmpty) return;
    final confirmed = await confirmVoteDialog(
      context,
      fairName: fairName,
      project: matches.first,
    );
    if (!confirmed) return;
    await controller.submit();
    onSubmitted();
  }
}
