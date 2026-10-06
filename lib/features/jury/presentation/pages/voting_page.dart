// voting_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import '../providers/jury_voting_status_provider.dart';
import '../voting/widgets/voting_body.dart';

/// `/jury/fair/:fairId/vote` — voto anónimo, uno por jurado.
///
/// Reglas: se bloquea si `isOpen == false` o `hasVoted == true`, y el botón
/// queda deshabilitado desde el primer tap hasta que el POST responda (el
/// backend rechaza el segundo voto con 409).
class VotingPage extends ConsumerWidget {
  const VotingPage({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(votingFormProvider(fairId));
    final controller = ref.read(votingFormProvider(fairId).notifier);

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Votación'),
      body: state.loading
          ? const AppLoader()
          : state.status == null
              ? AppErrorView(
                  message:
                      state.errorMessage ?? 'No se pudo cargar la votación',
                  onRetry: controller.load,
                )
              : VotingBody(
                  fairName: _fairName(ref),
                  state: state,
                  controller: controller,
                  // El estado de voting es la fuente de la fecha del voto en
                  // "Mi progreso".
                  onSubmitted: () =>
                      ref.invalidate(juryVotingStatusProvider(fairId)),
                ),
    );
  }

  /// Nombre real de la feria, si el tablero ya lo trajo.
  String? _fairName(WidgetRef ref) {
    final assignments = ref.watch(juryDashboardProvider).valueOrNull ??
        const <FairAssignmentModel>[];
    for (final assignment in assignments) {
      if (assignment.fairId == fairId) return assignment.name;
    }
    return null;
  }
}
