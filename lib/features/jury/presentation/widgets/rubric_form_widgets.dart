import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../providers/jury_providers.dart';
import '../providers/jury_state.dart';
import '../../../settings/presentation/settings_copy.dart';

/// Tarjeta de puntaje de la rúbrica: total sobre 20 y estado de la hoja.
class RubricScoreCard extends StatelessWidget {
  const RubricScoreCard({super.key, required this.state});

  final RubricFormState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final evaluation = state.evaluation!;
    final score = evaluation.score;

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(SettingsCopy.of(context).t('Puntaje'),
                    style: theme.textTheme.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  // El score solo existe cuando la hoja está finalizada.
                  score == null
                      ? SettingsCopy.of(context).t('Pendiente de finalizar')
                      : '${score.toStringAsFixed(1)} / 20',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          if (evaluation.submittedAt != null)
            StatusChip(
              label: SettingsCopy.of(context).t('Finalizado'),
              tone: AppTone.success,
              icon: Icons.check_circle_outline_rounded,
            ),
        ],
      ),
    );
  }
}

/// Pie de la rúbrica con las dos acciones del backend: guardar borrador y
/// finalizar (que exige cubrir todos los criterios activos).
class RubricActionsBar extends StatelessWidget {
  const RubricActionsBar({
    super.key,
    required this.state,
    required this.controller,
  });

  final RubricFormState state;
  final RubricFormController controller;

  @override
  Widget build(BuildContext context) {
    return ActionFooter(
      child: Row(
        children: [
          Expanded(
            child: AppButton.outlined(
              label: SettingsCopy.of(context).t('Guardar borrador'),
              onPressed:
                  state.saving ? null : () => controller.save(finalize: false),
              isLoading: state.saving,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: AppButton(
              label: SettingsCopy.of(context).t('Finalizar'),
              // El backend exige cubrir TODOS los criterios activos.
              onPressed: state.canFinalize
                  ? () => controller.save(finalize: true)
                  : null,
              isLoading: state.saving,
            ),
          ),
        ],
      ),
    );
  }
}
