import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_motion.dart';
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
                      icon: PhosphorIconsRegular.calendarCheck)),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                  child: _Metric(
                      value: '$assignedCount',
                      label: 'Asignadas',
                      icon: PhosphorIconsRegular.clipboardText)),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                  child: _Metric(
                      value: progressLabel,
                      label: 'Avance',
                      icon: PhosphorIconsRegular.listChecks)),
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
                    // La barra se llena desde 0 al entrar: el avance se lee
                    // como movimiento, no como un dato estático.
                    child: percentage == null
                        ? LinearProgressIndicator(
                            minHeight: 6,
                            color: accent,
                            backgroundColor: accent.withValues(alpha: 0.13),
                          )
                        : TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: percentage / 100),
                            duration: AppMotion.slow,
                            curve: AppMotion.emphasized,
                            builder: (_, v, __) => LinearProgressIndicator(
                              value: v,
                              minHeight: 6,
                              color: accent,
                              backgroundColor: accent.withValues(alpha: 0.13),
                            ),
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
            child: _countable(
              value,
              theme.textTheme.titleLarge?.copyWith(
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

/// Cifras enteras ("3", "40%") cuentan al aparecer; textos como "Cargando"
/// se muestran tal cual.
Widget _countable(String value, TextStyle? style) {
  final match = RegExp(r'^(\d+)(%?)$').firstMatch(value);
  if (match == null) return Text(value, style: style);
  return CountUpText(
    value: int.parse(match.group(1)!),
    suffix: match.group(2)!,
    style: style,
  );
}
