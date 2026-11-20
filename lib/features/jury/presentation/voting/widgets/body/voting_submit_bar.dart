// voting_submit_bar.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/core/widgets/app_button.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/jury/presentation/state/jury_state.dart'
    show VotingFormState;
import 'package:campusvote_flutter/features/jury/presentation/providers/forms/voting/voting_controller.dart'
    show VotingFormController;
import '../vote_confirm_dialog.dart';

/// Barra de acción fija al pie para confirmar el voto.
class VotingSubmitBar extends StatelessWidget {
  const VotingSubmitBar({
    super.key,
    required this.state,
    required this.controller,
    required this.onSubmitted,
  });

  final VotingFormState state;
  final VotingFormController controller;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final copy = SettingsCopy.of(context);
    String label;
    IconData icon = PhosphorIconsFill.checkSquareOffset;
    bool enabled = false;

    if (state.evaluationsLoading) {
      label = copy.t('Cargando evaluaciones...');
      icon = PhosphorIconsRegular.arrowClockwise;
    } else if (state.selectedProjectId == null) {
      label = copy.t('Selecciona un proyecto para continuar');
    } else if (!state.activeCategoryAllRubricsSubmitted) {
      final progress = state.activeCategoryProgress;
      final pending = progress?.pendingCount ?? 0;
      label = copy.t('Completa $pending rúbrica(s) pendiente(s) para votar');
      icon = PhosphorIconsRegular.lockSimple;
    } else if (!state.canVote) {
      label = copy.t('No puedes votar en este momento');
      icon = PhosphorIconsRegular.lockSimple;
    } else {
      label = copy.t('Revisar y confirmar voto');
      enabled = true;
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: AppButton(
          label: label,
          icon: icon,
          onPressed: enabled ? () => _confirmVote(context) : null,
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
      fairName: null,
      project: matches.first,
    );
    if (!confirmed) return;
    await controller.submit();
    onSubmitted();
  }
}