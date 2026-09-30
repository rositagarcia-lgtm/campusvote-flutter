import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../providers/jury_providers.dart';
import '../providers/jury_state.dart';
import '../widgets/voting_widgets.dart';

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
                  fairId: fairId,
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
    required this.fairId,
    required this.state,
    required this.controller,
  });

  final String fairId;
  final VotingFormState state;
  final VotingFormController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = state.status!;

    if (state.receipt != null) {
      return VoteReceiptView(receipt: state.receipt!);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Text(
                'Elige el proyecto que consideras ganador',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tu voto es anónimo: el backend solo guarda que participaste y '
                'te devuelve un comprobante.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.l),
              if (state.hasVoted)
                const NoticeBanner(
                  message:
                      'Ya emitiste tu voto en esta feria. No puedes repetirlo.',
                  tone: AppTone.success,
                  icon: Icons.check_circle_rounded,
                )
              else if (!status.isOpen)
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
              const SizedBox(height: AppSpacing.l),
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
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: AppButton(
              label: 'Emitir voto anónimo',
              icon: Icons.how_to_vote_rounded,
              // `canVote` ya incluye `!submitting`: el botón no se rearma
              // hasta que el POST termine.
              onPressed: state.canVote && state.selectedProjectId != null
                  ? () => controller.submit()
                  : null,
              isLoading: state.submitting,
            ),
          ),
        ),
      ],
    );
  }
}
