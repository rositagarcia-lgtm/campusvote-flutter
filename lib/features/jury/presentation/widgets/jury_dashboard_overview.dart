import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/greeting.dart';
import '../../../../core/widgets/app_motion.dart';
import '../providers/jury_dashboard_progress.dart';
import 'jury_overview_metric.dart';

/// Resumen de asignaciones y avance confirmado por el servidor.
class JuryDashboardOverview extends StatelessWidget {
  const JuryDashboardOverview({
    super.key,
    required this.openCount,
    required this.assignedCount,
    required this.progress,
    this.firstName,
  });

  final int openCount;
  final int assignedCount;
  final AsyncValue<JuryDashboardProgress> progress;

  /// Nombre de pila para el saludo; sin él, el título genérico.
  final String? firstName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = colors.primary;
    final firstName = firstNameOf(this.firstName);
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
          Text(
            timeGreeting(DateTime.now()).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Semantics(
            header: true,
            child: Text(
              firstName == null
                  ? 'Tus ferias asignadas'
                  : 'Hola, $firstName',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            openCount == 0
                ? 'Aquí verás tus ferias cuando cierre la inscripción o empiecen.'
                : openCount == 1
                    ? 'Tienes 1 feria en curso. Todo lo que necesitas está abajo.'
                    : 'Tienes $openCount ferias en curso. Todo lo que necesitas está abajo.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: JuryOverviewMetric(
                      value: '$openCount',
                      label: 'En curso',
                      icon: PhosphorIconsRegular.calendarCheck)),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                  child: JuryOverviewMetric(
                      value: '$assignedCount',
                      label: 'Asignadas',
                      icon: PhosphorIconsRegular.clipboardText)),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Semantics(
            label: 'Avance: $progressLabel. $detail',
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.rLarge,
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(PhosphorIconsRegular.listChecks,
                          size: 20, color: accent),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text('Avance de rúbricas',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Text(progressLabel,
                          style: (percentage == null
                                  ? theme.textTheme.labelLarge
                                  : theme.textTheme.titleLarge)
                              ?.copyWith(
                            color: percentage == null
                                ? colors.onSurfaceVariant
                                : accent,
                            fontWeight: FontWeight.w800,
                          )),
                    ],
                  ),
                  if (percentage != null || progress.isLoading) ...[
                    const SizedBox(height: AppSpacing.m),
                    ClipRRect(
                      borderRadius: AppRadii.rMedium,
                      child: percentage == null
                          ? LinearProgressIndicator(
                              minHeight: 8,
                              color: accent,
                              backgroundColor: accent.withValues(alpha: 0.13),
                            )
                          : TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: percentage / 100),
                              duration: AppMotion.reduced(context)
                                  ? Duration.zero
                                  : AppMotion.slow,
                              curve: AppMotion.emphasized,
                              builder: (_, value, __) =>
                                  LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                color: accent,
                                backgroundColor: accent.withValues(alpha: 0.13),
                              ),
                            ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s),
                  Text(detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
