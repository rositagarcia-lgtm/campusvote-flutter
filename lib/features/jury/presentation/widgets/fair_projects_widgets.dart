import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../data/models/jury_models.dart';

/// Resumen de progreso del jurado con barra y porcentaje.
class ProgressBanner extends StatelessWidget {
  const ProgressBanner({super.key, required this.progress});

  final JuryProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final done = progress.completedProjects;
    final total = progress.totalProjects;
    final ratio = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;

    return Semantics(
      button: true,
      label: 'Evaluaste $done de $total proyectos. Ver mi progreso',
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLarge,
          side: BorderSide(color: appBorder(isDark)),
        ),
        child: InkWell(
          onTap: () => context.push('/jury/fair/${progress.fairId}/progress'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  label: 'Tu progreso',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: appMuted(isDark),
                  ),
                ),
                Text(
                  'Evaluaste $done de $total proyectos',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: AppRadii.rSmall,
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          color: accent,
                          backgroundColor:
                              accent.withValues(alpha: isDark ? 0.20 : 0.12),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Text(
                      '${(ratio * 100).round()}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Accesos del jurado a su progreso y a la votación oficial.
class FairActionsBar extends StatelessWidget {
  const FairActionsBar({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.insights_rounded,
            label: 'Progreso',
            onTap: () => context.push('/jury/fair/$fairId/progress'),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _ActionTile(
            icon: Icons.how_to_vote_rounded,
            label: 'Votar',
            onTap: () => context.push('/jury/fair/$fairId/vote'),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final tint = accent.withValues(alpha: isDark ? 0.16 : 0.08);

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLarge,
          side: BorderSide(color: appBorder(isDark)),
        ),
        child: InkWell(
          onTap: onTap,
          splashColor: tint,
          highlightColor: tint,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
            child: Column(
              children: [
                Container(
                  width: AppDimensions.touchTarget,
                  height: AppDimensions.touchTarget,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: AppRadii.rMedium,
                  ),
                  child:
                      Icon(icon, size: AppDimensions.iconLarge, color: accent),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  label,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
