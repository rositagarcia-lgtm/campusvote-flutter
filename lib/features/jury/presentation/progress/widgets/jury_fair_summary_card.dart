import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_palette.dart';
import '../../../../../core/widgets/app_status_chip.dart';
import '../../../../settings/presentation/settings_copy.dart';
import '../../../data/models/jury_models.dart';
import '../../widgets/jury_progress_bar.dart';
import '../../widgets/voting_countdown.dart';
import 'jury_panel.dart';
import 'jury_split_legend.dart';

/// Identidad de la feria asignada: nombre, estado y los metadatos que la
/// asignación trae de verdad (sede y ventana de la feria).
///
/// Lo que el backend no envía (sede, fechas) se omite en lugar de rellenarse con
/// textos de ejemplo.
class JuryFairSummaryCard extends StatelessWidget {
  const JuryFairSummaryCard({
    super.key,
    required this.progress,
    this.assignment,
  });

  final JuryProgressModel progress;

  /// Asignación de la feria (`GET /fairs/my-assignments`); aporta sede y
  /// fechas. Si no está cargada, la tarjeta se muestra solo con el progreso.
  final FairAssignmentModel? assignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = SettingsCopy.of(context);
    final status = _status;
    final open = progress.fairStatus == FairStatus.open;
    final site = assignment?.siteName;
    final endsAt = assignment?.endsAt;
    final name = progress.fairName?.trim();

    return JuryPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: JuryOverline(text: text.t('FERIA ASIGNADA')),
              ),
              StatusChip(
                label: text.t(status.$1),
                tone: status.$2,
                icon: open
                    ? Icons.radio_button_checked_rounded
                    : Icons.lock_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            name == null || name.isEmpty ? text.t('Feria asignada') : name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          if (site != null && site.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            JuryMetaRow(
              icon: Icons.place_outlined,
              text: site.trim(),
            ),
          ],
          if (open && endsAt != null) ...[
            const SizedBox(height: AppSpacing.m),
            VotingCountdown(endsAt: endsAt, startsAt: assignment?.startsAt),
          ],
        ],
      ),
    );
  }

  /// Estado real de la feria (`JuryProgressModel.fairStatus`) y su tono.
  (String, AppTone) get _status => switch (progress.fairStatus) {
        FairStatus.open => ('Abierta', AppTone.success),
        FairStatus.closed => ('Cerrada', AppTone.neutral),
        FairStatus.draft => ('En preparación', AppTone.warning),
        FairStatus.unknown => ('Estado sin confirmar', AppTone.neutral),
      };
}

/// Avance real de las evaluaciones por rúbrica.
///
/// El porcentaje es solo de evaluaciones (`progress_percentage` del backend):
/// la votación y la declaración se muestran aparte, nunca sumadas.
class JuryEvaluationProgressCard extends StatelessWidget {
  const JuryEvaluationProgressCard({super.key, required this.progress});

  final JuryProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = appMuted(theme.brightness == Brightness.dark);
    final text = SettingsCopy.of(context);

    return JuryPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JuryOverline(text: text.t('EVALUACIÓN DE PROYECTOS')),
          const SizedBox(height: AppSpacing.s),
          Text(
            text.t(
              'Cada proyecto se califica con los criterios de su rúbrica. '
              'Esta evaluación no es tu voto oficial.',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          JuryProgressBar(
            completed: progress.completedProjects,
            total: progress.totalProjects,
            percentage: progress.progressPercentage,
            label: text.t('Rúbricas finalizadas'),
            showCaption: false,
          ),
          const SizedBox(height: AppSpacing.m),
          JurySplitLegend(
            evaluated: progress.completedProjects,
            pending: progress.pendingProjects,
          ),
        ],
      ),
    );
  }
}
