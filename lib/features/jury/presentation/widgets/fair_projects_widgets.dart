import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../data/models/jury_models.dart';

class ProgressBanner extends StatelessWidget {
  const ProgressBanner({super.key, required this.progress});

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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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

class FairActionsBar extends StatelessWidget {
  const FairActionsBar({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context) {
    final progress = AppButton.outlined(
      label: 'Mi progreso',
      icon: Icons.checklist_rounded,
      dense: true,
      onPressed: () => context.push('/jury/fair/$fairId/progress'),
    );
    final vote = AppButton(
      label: 'Votación oficial',
      icon: Icons.how_to_vote_outlined,
      dense: true,
      onPressed: () => context.push('/jury/fair/$fairId/vote'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              vote,
              const SizedBox(height: AppSpacing.s),
              progress,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: progress),
            const SizedBox(width: AppSpacing.s),
            Expanded(child: vote),
          ],
        );
      },
    );
  }
}
