import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../providers/jury_providers.dart';
import '../providers/jury_state.dart';

/// Tarjeta de puntaje: anillo de avance que se llena al marcar criterios y,
/// cuando la hoja está finalizada, el puntaje sobre 20.
class RubricScoreCard extends StatelessWidget {
  const RubricScoreCard({super.key, required this.state});

  final RubricFormState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final evaluation = state.evaluation!;
    final score = evaluation.score;
    final total = evaluation.rubric.criteria.length;
    final checked = state.checkedCount;
    final ratio = total == 0 ? 0.0 : checked / total;

    return AppCard(
      child: Row(
        children: [
          SizedBox.square(
            dimension: 72,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: ratio),
              duration:
                  AppMotion.reduced(context) ? Duration.zero : AppMotion.medium,
              curve: AppMotion.emphasized,
              builder: (_, v, __) => Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: v,
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                    color: scheme.primary,
                    backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  ),
                  Center(
                    child: Text(
                      '$checked/$total',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Puntaje', style: theme.textTheme.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  // El score solo existe cuando la hoja está finalizada.
                  score == null
                      ? 'Pendiente de finalizar'
                      : '${score.toStringAsFixed(1)} / 20',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$checked de $total criterios marcados',
                  style: theme.textTheme.bodySmall,
                ),
                if (evaluation.submittedAt != null) ...[
                  const SizedBox(height: AppSpacing.s),
                  const StatusChip(
                    label: 'Finalizado',
                    tone: AppTone.success,
                    icon: PhosphorIconsRegular.checkCircle,
                  ),
                ],
              ],
            ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final draft = AppButton.outlined(
            label: 'Guardar borrador',
            onPressed:
                state.saving ? null : () => controller.save(finalize: false),
            isLoading: state.saving,
          );
          final submit = AppButton(
            label: 'Finalizar',
            // El backend exige cubrir TODOS los criterios activos.
            onPressed: state.canFinalize
                ? () => controller.save(finalize: true)
                : null,
            isLoading: state.saving,
          );
          if (constraints.maxWidth < 360) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [submit, const SizedBox(height: AppSpacing.s), draft],
            );
          }
          return Row(
            children: [
              Expanded(child: draft),
              const SizedBox(width: AppSpacing.m),
              Expanded(child: submit),
            ],
          );
        },
      ),
    );
  }
}
