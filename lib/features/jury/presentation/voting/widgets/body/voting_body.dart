// voting_body.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/core/widgets/app_button.dart';
import 'package:campusvote_flutter/core/widgets/app_motion.dart';
import 'package:campusvote_flutter/core/widgets/app_notice.dart';
import 'package:campusvote_flutter/core/widgets/app_status_chip.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/presentation/state/jury_state.dart'
    show VotingFormState;
import 'package:campusvote_flutter/features/jury/presentation/providers/forms/voting/voting_controller.dart'
    show VotingFormController;
import 'package:campusvote_flutter/features/jury/presentation/voting/widgets/projects/voting_projects.dart'
    show buildVotingProjects;
import 'voting_submit_bar.dart';
import '../voting_widgets.dart';
import 'voting_hero_section.dart';

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

    final next = state.nextPendingCategory;
    if (state.receipt != null) {
      final receipt = VoteReceiptView(receipt: state.receipt!);
      if (next == null) return receipt;
      // Jurado con excepción: le falta votar en otra categoría asignada.
      return Column(
        children: [
          Expanded(child: receipt),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: AppButton(
                label: 'Votar en ${next.name}',
                icon: PhosphorIconsRegular.arrowRight,
                onPressed: () => controller.selectCategory(next.id),
              ),
            ),
          ),
        ],
      );
    }
    if (state.hasVoted) {
      final voted = VoteParticipationView(status: status);
      if (next == null) return voted;
      // Ya votó en esta categoría; le falta otra asignada (excepción).
      return Column(
        children: [
          Expanded(child: voted),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: AppButton(
                label: 'Votar en ${next.name}',
                icon: PhosphorIconsRegular.arrowRight,
                onPressed: () => controller.selectCategory(next.id),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              AppMotion.reveal(
                0,
                VotingHero(
                  fairName: fairName,
                  status: status,
                ),
              ),
              if (state.categories.length > 1) ...[
                const SizedBox(height: AppSpacing.m),
                // Excepción: varias categorías asignadas, un voto en cada una.
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  children: [
                    for (final c in state.categories)
                      ChoiceChip(
                        selected: c.id == state.activeCategoryId,
                        avatar: c.hasVoted
                            ? const Icon(PhosphorIconsFill.checkCircle,
                                size: 16)
                            : null,
                        label: Text(c.name),
                        onSelected: state.submitting
                            ? null
                            : (_) => controller.selectCategory(c.id),
                      ),
                  ],
                ),
              ] else if (state.activeCategory != null) ...[
                const SizedBox(height: AppSpacing.m),
                StatusChip(
                  label: SettingsCopy.of(context).isEnglish
                      ? 'Your category: ${state.activeCategory!.name}'
                      : 'Tu categoría: ${state.activeCategory!.name}',
                  tone: AppTone.primary,
                  icon: PhosphorIconsRegular.squaresFour,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (!status.isOpen)
                const NoticeBanner(
                  message:
                      'La votación está cerrada: la feria no está abierta.',
                  tone: AppTone.warning,
                  icon: PhosphorIconsFill.lockSimple,
                )
              else if (status.notStarted)
                NoticeBanner(
                  message: status.startsAt == null
                      ? 'La votación empieza cuando inicia la feria.'
                      : (SettingsCopy.of(context).isEnglish
                          ? 'Voting opens on ${_when(context, status.startsAt!)}. You can review the projects in the meantime.'
                          : 'La votación abre el ${_when(context, status.startsAt!)}. Puedes revisar los proyectos mientras tanto.'),
                  tone: AppTone.info,
                  icon: PhosphorIconsRegular.clock,
                )
              else if (status.ended)
                const NoticeBanner(
                  message: 'El período de votación de esta feria terminó.',
                  tone: AppTone.warning,
                  icon: PhosphorIconsFill.lockSimple,
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
                  icon: PhosphorIconsRegular.cloudArrowUp,
                  liveRegion: true,
                ),
                const SizedBox(height: AppSpacing.s),
                AppButton.outlined(
                  label: 'Consultar estado de votación',
                  icon: PhosphorIconsRegular.arrowClockwise,
                  onPressed: state.loading ? null : controller.refreshStatus,
                  isLoading: state.loading,
                ),
              ],
              if (state.evaluationsLoading) ...[
                const SizedBox(height: AppSpacing.m),
                const NoticeBanner(
                  message:
                      'Verificando estado de tus rúbricas... La votación se habilitará cuando se confirme que todas están completadas.',
                  tone: AppTone.info,
                  icon: PhosphorIconsRegular.arrowClockwise,
                  liveRegion: true,
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              buildVotingProjects(context, theme, state, controller),
            ],
          ),
        ),
        VotingSubmitBar(
          state: state,
          controller: controller,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }

  /// Fecha y hora local legible ("10/10/2026 22:00").
  String _when(BuildContext context, DateTime date) {
    final local = date.toLocal();
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMd(locale).add_Hm().format(local);
  }
}