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

// ── Resultados de la feria ──────────────────────────────────────────────────

/// `GET /fairs/:fairId/results` — ADMIN-only: un JURY recibe 403.
final fairResultsProvider =
    AsyncNotifierProvider.family<FairResultsNotifier, FairResultsModel, String>(
        FairResultsNotifier.new);

class FairResultsNotifier
    extends FamilyAsyncNotifier<FairResultsModel, String> {
  @override
  Future<FairResultsModel> build(String fairId) {
    return ref.read(juryRepositoryProvider).getResults(fairId);
  }

  /// Reintento manual de la pantalla de resultados: sin esto el botón de
  /// reintentar no dispara nada y la pantalla se queda en el mismo error.
  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(juryRepositoryProvider).getResults(arg),
    );
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
