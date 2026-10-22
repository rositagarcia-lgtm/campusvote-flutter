// fairs/jury_fair_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/jury_models.dart';
import '../data/jury_dependencies.dart';

// ── Dashboard de ferias ─────────────────────────────────────────────────────

/// `GET /fairs/my-assignments`
final juryDashboardProvider =
    AsyncNotifierProvider<JuryDashboardNotifier, List<FairAssignmentModel>>(
        JuryDashboardNotifier.new);

class JuryDashboardNotifier extends AsyncNotifier<List<FairAssignmentModel>> {
  @override
  Future<List<FairAssignmentModel>> build() async {
    final page = await ref.read(juryRepositoryProvider).getMyAssignments();
    return page.items;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async =>
          (await ref.read(juryRepositoryProvider).getMyAssignments()).items,
    );
  }
}

/// Asignación (fase y fechas) de una feria, tomada de `my-assignments`.
/// Nulo mientras carga: las pantallas no asumen vista previa sin saberlo.
final juryFairAssignmentProvider =
    Provider.family<FairAssignmentModel?, String>((ref, fairId) => ref
        .watch(juryDashboardProvider)
        .valueOrNull
        ?.where((fair) => fair.fairId == fairId)
        .firstOrNull);

/// Vista previa: el jurado estudia, pero aún no evalúa, vota ni reseña.
final juryFairInPreviewProvider = Provider.family<bool, String>((ref, fairId) =>
    ref.watch(juryFairAssignmentProvider(fairId))?.phase == JuryPhase.preview);

// ── Proyectos de la feria ───────────────────────────────────────────────────

/// `GET /fairs/:fairId/projects` — NO se re-filtra en Flutter (regla 7).
final fairProjectsProvider = AsyncNotifierProvider.family<FairProjectsNotifier,
    List<FairProjectModel>, String>(
  FairProjectsNotifier.new,
);

class FairProjectsNotifier
    extends FamilyAsyncNotifier<List<FairProjectModel>, String> {
  @override
  Future<List<FairProjectModel>> build(String fairId) async {
    final repository = ref.read(juryRepositoryProvider);
    final first = await repository.getFairProjects(fairId);
    final projects = [...first.items];
    for (var page = 2; page <= first.totalPages; page++) {
      projects
          .addAll((await repository.getFairProjects(fairId, page: page)).items);
    }
    return projects;
  }
}

// ── Mis evaluaciones ────────────────────────────────────────────────────────

/// `GET /fairs/my-evaluations` (opcionalmente `?fair_id=`).
final myEvaluationsProvider = AsyncNotifierProvider.family<
    MyEvaluationsNotifier,
    List<JuryEvaluationSummaryModel>,
    String?>(MyEvaluationsNotifier.new);

class MyEvaluationsNotifier
    extends FamilyAsyncNotifier<List<JuryEvaluationSummaryModel>, String?> {
  @override
  Future<List<JuryEvaluationSummaryModel>> build(String? fairId) async {
    final repository = ref.read(juryRepositoryProvider);
    final first = await repository.getMyEvaluations(fairId: fairId);
    final evaluations = [...first.items];
    for (var page = 2; page <= first.totalPages; page++) {
      evaluations.addAll((await repository.getMyEvaluations(
        fairId: fairId,
        page: page,
      ))
          .items);
    }
    return evaluations;
  }
}
