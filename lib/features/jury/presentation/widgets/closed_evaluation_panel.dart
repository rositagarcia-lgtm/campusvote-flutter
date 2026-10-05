import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/jury_models.dart';
import '../../../settings/presentation/settings_copy.dart';

/// Panel de solo lectura para una rúbrica finalizada e inmutable.
class ClosedEvaluationPanel extends StatelessWidget {
  final RubricEvaluationModel evaluation;
  final VoidCallback onBack;

  const ClosedEvaluationPanel({
    super.key,
    required this.evaluation,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = evaluation.score;
    final isDark = theme.brightness == Brightness.dark;
    final text = SettingsCopy.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        AppCard(
          elevated: true,
          child: Column(
            children: [
              Container(
                width: AppDimensions.touchTarget + AppSpacing.l,
                height: AppDimensions.touchTarget + AppSpacing.l,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimarySoft
                      : AppColors.successSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppColors.success,
                  size: AppDimensions.iconLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                text.t('Evaluación cerrada'),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                text.t('Esta rúbrica ya fue finalizada y no admite cambios.'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              if (evaluation.projectName != null) ...[
                const SizedBox(height: AppSpacing.l),
                Text(
                  evaluation.projectName!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              _SummaryRow(
                label: text.t('Puntaje final'),
                value: score == null
                    ? text.t('No disponible')
                    : '${score.toStringAsFixed(1)} / 20',
              ),
              _SummaryRow(
                label: text.t('Criterios marcados'),
                value: text.selectedCriteria(
                  evaluation.checkedCount ?? 0,
                  evaluation.criteriaCount ?? evaluation.totalCriteria,
                ),
              ),
              if (evaluation.submittedAt != null)
                _SummaryRow(
                  label: text.t('Finalizada'),
                  value: text.formatDate(evaluation.submittedAt!),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        AppButton.outlined(
          label: text.t('Volver a proyectos'),
          icon: Icons.arrow_back_rounded,
          onPressed: onBack,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
