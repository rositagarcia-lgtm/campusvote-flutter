import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_notice.dart';
import '../../../../../core/widgets/app_page_layout.dart';
import '../../../../../core/widgets/app_section_header.dart';
import '../../../../../core/widgets/app_status_chip.dart';
import '../../../../settings/presentation/settings_copy.dart';
import '../../../data/models/jury_models.dart';
import '../jury_flow.dart';
import '../../providers/jury_providers.dart';
import '../../providers/jury_voting_status_provider.dart';
import 'jury_fair_summary_card.dart';
import 'jury_flow_timeline.dart';
import 'jury_progress_actions.dart';
import 'jury_progress_notice.dart';

/// Cuerpo de `/jury/fair/:fairId/progress` con los datos ya cargados.
///
/// Compone las piezas en el orden en que el jurado trabaja: contexto de la
/// feria, avance de rúbricas, situación actual, flujo completo y acciones.
class JuryProgressView extends ConsumerWidget {
  const JuryProgressView({
    super.key,
    required this.fairId,
    required this.progress,
    this.staleError = false,
  });

  final String fairId;
  final JuryProgressModel progress;

  /// La recarga falló y se está mostrando la última información confirmada.
  final bool staleError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voting = ref.watch(juryVotingStatusProvider(fairId));
    final text = SettingsCopy.of(context);
    final flow = JuryFlow.fromProgress(
      progress,
      votedAt: voting.valueOrNull?.votedAt,
    );

    return PageScrollBody(
      // Siempre desplazable para que el gesto de recargar funcione aunque la
      // feria tenga poco contenido.
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (staleError) ...[
            const NoticeBanner(
              tone: AppTone.danger,
              liveRegion: true,
              message:
                  'No pudimos actualizar tu progreso. Se muestra la última '
                  'información confirmada.',
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          JuryFairSummaryCard(
            progress: progress,
            assignment: _assignment(ref, fairId),
          ),
          const SizedBox(height: AppSpacing.m),
          JuryEvaluationProgressCard(progress: progress),
          const SizedBox(height: AppSpacing.l),
          JuryProgressNotice(flow: flow),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            label: text.t('FLUJO DEL JURADO'),
            title: text.t('Tu participación'),
            count: flow.remainingSteps,
          ),
          JuryFlowTimeline(stages: flow.stages),
          if (progress.declaration?.statement case final statement?) ...[
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(label: text.t('DECLARACIÓN REGISTRADA')),
            const SizedBox(height: AppSpacing.s),
            Text(
              statement,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          JuryProgressActions(flow: flow, onGoTo: (a) => _go(context, a)),
        ],
      ),
    );
  }

  /// Asignación de esta feria, usada solo para sede y fechas reales. Si el
  /// tablero aún no cargó, la tarjeta omite esos datos.
  FairAssignmentModel? _assignment(WidgetRef ref, String fairId) {
    final assignments = ref.watch(juryDashboardProvider).valueOrNull;
    if (assignments == null) return null;
    for (final fair in assignments) {
      if (fair.fairId == fairId) return fair;
    }
    return null;
  }

  /// Traduce una acción del flujo a la ruta real del router.
  void _go(BuildContext context, JuryStageAction action) {
    switch (action) {
      case JuryStageAction.projects:
        context.push('/jury/fair/$fairId');
      case JuryStageAction.voting:
        context.push('/jury/fair/$fairId/vote');
      case JuryStageAction.declaration:
        context.push('/jury/fair/$fairId/declaration');
    }
  }
}
