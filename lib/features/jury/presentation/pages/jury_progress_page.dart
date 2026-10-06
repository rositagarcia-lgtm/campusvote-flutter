// jury_progress_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/organization_panel_app_bar.dart';
import '../../data/models/jury_models.dart';
import '../progress/widgets/jury_progress_skeleton.dart';
import '../progress/widgets/jury_progress_view.dart';
import '../providers/jury_providers.dart';
import '../providers/jury_voting_status_provider.dart';

/// `/jury/fair/:fairId/progress` — estado real de la participación del jurado.
///
/// Todo lo que se muestra sale de `GET /fairs/my-progress/:fairId` (y del estado
/// de votación para la fecha del voto). El contenido vive en
/// `presentation/progress/`; esta pantalla solo resuelve datos y estados de
/// carga, error y recarga.
class JuryProgressPage extends ConsumerWidget {
  const JuryProgressPage({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(juryProgressProvider(fairId));
    final branding = ref.watch(brandingControllerProvider);
    // Se lee el valor con `valueOrNull` para que una recarga no borre lo que
    // ya está en pantalla; el error se reporta aparte sobre esos mismos datos.
    final data = progress.valueOrNull;

    return Scaffold(
      appBar: OrganizationPanelAppBar(
        branding: branding,
        section: 'Mi progreso',
        onBack: () => context.pop(),
      ),
      body: RefreshIndicator(
        onRefresh: () => reloadJuryProgress(context, ref, fairId),
        child: data != null
            ? JuryProgressView(
                fairId: fairId,
                progress: data,
                staleError: progress.hasError,
              )
            : switch (progress) {
                AsyncError(:final error) => AppErrorView(
                    message: describeJuryError(error),
                    onRetry: () => reloadJuryProgress(context, ref, fairId),
                  ),
                _ => const JuryProgressSkeleton(),
              },
      ),
    );
  }
}

/// Recarga el progreso y avisa si, tras la acción, algún paso se completó.
Future<void> reloadJuryProgress(
  BuildContext context,
  WidgetRef ref,
  String fairId,
) async {
  final before = ref.read(juryProgressProvider(fairId)).valueOrNull;
  try {
    ref.invalidate(juryVotingStatusProvider(fairId));
    await ref.read(juryProgressProvider(fairId).notifier).reload();
  } catch (_) {
    // El estado ya quedó en `AsyncError` y la pantalla lo muestra.
  }
  if (!context.mounted) return;
  final message = completedMessage(
    before,
    ref.read(juryProgressProvider(fairId)).valueOrNull,
  );
  if (message == null) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Resumen de lo que cambió tras una acción: solo hechos del modelo.
String? completedMessage(JuryProgressModel? before, JuryProgressModel? after) {
  if (before == null || after == null) return null;
  final done = <String>[
    if (!before.isComplete && after.isComplete) 'Evaluaciones finalizadas',
    if (!before.hasVoted && after.hasVoted) 'Voto oficial registrado',
    if (before.declaration == null && after.declaration != null)
      'Declaración registrada',
  ];
  if (done.isEmpty) return null;
  return '${done.join(' · ')}. Tu progreso está actualizado.';
}
