import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../providers/jury_dashboard_progress.dart';

/// Resumen de asignaciones y avance confirmado por el servidor.
class JuryDashboardOverview extends StatelessWidget {
  const JuryDashboardOverview({
    super.key,
    required this.openCount,
    required this.assignedCount,
    required this.progress,
  });

  final int openCount;
  final int assignedCount;
  final AsyncValue<JuryDashboardProgress> progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = colors.primary;
    final isDark = theme.brightness == Brightness.dark;
    final data = progress.valueOrNull;
    final percentage =
        progress.isLoading || progress.hasError ? null : data?.percentage;
    final progressLabel = progress.isLoading
        ? 'Cargando'
        : progress.hasError
            ? 'No disponible'
            : percentage == null
                ? 'Sin datos'
                : '$percentage%';
    final detail = progress.isLoading
        ? 'Consultando las evaluaciones registradas'
        : progress.hasError
            ? 'No se pudo consultar el avance. Desliza para reintentar.'
            : data == null || data.total == 0
                ? 'Aún no hay proyectos evaluables en tus ferias abiertas.'
                : '${data.completed} de ${data.total} proyectos evaluados en ferias abiertas';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(alpha: isDark ? 0.15 : 0.055),
          colors.surface,
        ),
        borderRadius: AppRadii.rXLarge,
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: AppRadii.rXLarge,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_outlined, size: 17, color: accent),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      'Panel del jurado',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Semantics(
            header: true,
            child: Text(
              'Tus ferias asignadas',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Consulta tus ferias y el avance de las evaluaciones registradas.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _Metric(
                      value: '$openCount',
                      label: 'Abiertas',
                      icon: Icons.event_available_outlined)),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                  child: _Metric(
                      value: '$assignedCount',
                      label: 'Asignadas',
                      icon: Icons.assignment_outlined)),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                  child: _Metric(
                      value: progressLabel,
                      label: 'Avance',
                      icon: Icons.fact_check_outlined)),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Semantics(
            label: detail,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (percentage != null || progress.isLoading) ...[
                  ClipRRect(
                    borderRadius: AppRadii.rMedium,
                    child: LinearProgressIndicator(
                      value: percentage == null ? null : percentage / 100,
                      minHeight: 6,
                      color: accent,
                      backgroundColor: accent.withValues(alpha: 0.13),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                ],
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
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

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: colors.primary.withValues(alpha: 0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: colors.primary),
          const SizedBox(height: AppSpacing.s),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 2,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
