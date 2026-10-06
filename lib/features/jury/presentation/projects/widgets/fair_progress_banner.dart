// fair_progress_banner.dart

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_palette.dart';
import '../../../data/models/jury_models.dart';

/// Avance de la evaluación en la feria.
///
/// El progreso viene del endpoint de progreso, así que no hace falta pedirlo
/// aparte por cada proyecto de la lista.
class FairProgressBanner extends StatelessWidget {
  const FairProgressBanner({super.key, required this.progress});

  final JuryProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = progress.completedProjects;
    final total = progress.totalProjects;
    final ratio = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;
    final muted = appMuted(theme.brightness == Brightness.dark);

    return Semantics(
      label: 'Progreso de evaluación: $done de $total proyectos',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tu progreso',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$done de $total',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          ClipRRect(
            borderRadius: AppRadii.rSmall,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              color: theme.colorScheme.primary,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}