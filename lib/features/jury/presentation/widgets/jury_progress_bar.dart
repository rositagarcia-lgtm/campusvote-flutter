import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';

/// Barra de avance del jurado: `evaluatedProjects / totalProjects`.
///
/// Acepta los números sueltos o un ratio 0–1; muestra también el porcentaje
/// que devuelve el backend (`progress_percentage`) cuando está disponible.
class JuryProgressBar extends StatelessWidget {
  const JuryProgressBar({
    super.key,
    this.completed = 0,
    this.total = 0,
    this.ratio,
    this.percentage,
    this.label,
  });

  final int completed;
  final int total;

  /// Alternativa a `completed/total` cuando el dato viene ya calculado.
  final double? ratio;

  /// Porcentaje entero del backend (0–100).
  final int? percentage;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value =
        (ratio ?? (total == 0 ? 0 : completed / total)).clamp(0.0, 1.0);
    final percent = percentage ?? (value * 100).round();
    final complete = value >= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label ?? 'Progreso de evaluación',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$percent%',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.brandPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        ClipRRect(
          borderRadius: AppRadii.rSmall,
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: context.brandPrimarySoft,
            valueColor: AlwaysStoppedAnimation<Color>(context.brandPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          total == 0
              ? 'La feria aún no tiene proyectos evaluables'
              : '$completed de $total proyectos evaluados${complete ? ' · completado' : ''}',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
