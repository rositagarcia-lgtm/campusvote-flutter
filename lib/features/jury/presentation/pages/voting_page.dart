import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import '../providers/jury_state.dart';

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
      return _ReceiptView(receipt: state.receipt!);
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
                const _Notice(
                  icon: Icons.check_circle_rounded,
                  text:
                      'Ya emitiste tu voto en esta feria. No puedes repetirlo.',
                )
              else if (!status.isOpen)
                const _Notice(
                  icon: Icons.lock_rounded,
                  text: 'La votación está cerrada: la feria no está abierta.',
                ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.m),
                _Notice(
                  icon: Icons.error_outline_rounded,
                  text: state.errorMessage!,
                  isError: true,
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              for (final project in state.projects) ...[
                _ProjectOption(
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

class _ProjectOption extends StatelessWidget {
  const _ProjectOption({
    required this.project,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final FairProjectModel project;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      borderRadius: AppRadii.rMedium,
      child: InkWell(
        borderRadius: AppRadii.rMedium,
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              // Radio propio: `Radio` deprecó `groupValue`/`onChanged` y la
              // pantalla solo necesita un indicador de selección.
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color:
                    selected ? theme.colorScheme.primary : theme.disabledColor,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (project.categoryName != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(project.categoryName!,
                          style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, this.isError = false});

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isError
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.rMedium,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isError ? theme.colorScheme.error : null),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _ReceiptView extends StatelessWidget {
  const _ReceiptView({required this.receipt});

  final VoteReceiptModel receipt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.verified_rounded,
              size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Voto registrado',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Guarda este comprobante. No muestra por quién votaste, '
            'solo que participaste.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.l),
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: AppRadii.rMedium,
            ),
            child: Column(
              children: [
                Text('Comprobante', style: theme.textTheme.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                SelectableText(
                  receipt.receiptCode,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
