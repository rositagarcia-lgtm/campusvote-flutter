import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_palette.dart';
import '../../../../../core/widgets/app_status_chip.dart';
import '../../../../settings/presentation/settings_copy.dart';
import '../jury_flow.dart';
import 'jury_panel.dart';

/// Una etapa del flujo del jurado: estado y detalle de lo que corresponde hacer.
///
/// Es información, no un botón: la pantalla ofrece cada destino una sola vez en
/// el panel de acciones. El estado nunca se comunica solo con color: lleva chip,
/// ícono y texto.
class JuryFlowStep extends StatelessWidget {
  const JuryFlowStep({super.key, required this.stage});

  final JuryFlowStage stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final text = SettingsCopy.of(context);
    final tone = _tone;
    final colors = appToneColors(
      tone,
      isDark: isDark,
      primary: theme.colorScheme.primary,
    );

    return Semantics(
      container: true,
      child: JuryPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JuryPanelIcon(icon: stage.icon, color: colors.fg),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text.t(stage.title),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: StatusChip(
                          label: text.t(stage.statusLabel),
                          tone: tone,
                          showDot: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              text.t(stage.description),
              style: theme.textTheme.bodySmall?.copyWith(
                color: appMuted(isDark),
                height: 1.45,
              ),
            ),
            if (stage.noteAt != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                text.recordedOn(stage.noteAt!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: appMuted(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  AppTone get _tone => switch (stage.status) {
        JuryStageStatus.done => AppTone.success,
        JuryStageStatus.active => AppTone.primary,
        JuryStageStatus.pending => AppTone.warning,
        JuryStageStatus.blocked => AppTone.neutral,
      };
}

/// Las etapas del flujo en orden, unidas por una guía vertical.
class JuryFlowTimeline extends StatelessWidget {
  const JuryFlowTimeline({super.key, required this.stages});

  final List<JuryFlowStage> stages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 2,
                  height: 14,
                  color: appBorder(isDark),
                ),
              ),
            ),
          JuryFlowStep(stage: stages[i]),
        ],
        const SizedBox(height: AppSpacing.s),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            SettingsCopy.of(context).t(
              'Los estados reflejan lo que el sistema tiene registrado para ti.',
            ),
            style:
                theme.textTheme.labelSmall?.copyWith(color: appMuted(isDark)),
          ),
        ),
      ],
    );
  }
}
