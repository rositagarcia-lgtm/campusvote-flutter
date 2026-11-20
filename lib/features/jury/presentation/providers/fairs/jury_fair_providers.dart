// fairs/jury_fair_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/jury_models.dart';
import '../data/jury_dependencies.dart';
import '../jury_state.dart';

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

// ── Progreso de rúbricas por categoría (para habilitar votación) ────────────

/// Progreso de rúbricas por categoría para una feria.
/// Combina proyectos asignados + evaluaciones persistidas (submitted == true).
final categoryRubricProgressProvider = FutureProvider.family<
    Map<String, CategoryRubricProgress>, String>((ref, fairId) async {
  final repository = ref.read(juryRepositoryProvider);

  // Cargar proyectos y evaluaciones en paralelo
  final results = await Future.wait([
    repository.getFairProjects(fairId),
    repository.getMyEvaluations(fairId: fairId, page: 1, limit: 200),
  ]);

  final firstProjects = results[0] as PaginatedResult<FairProjectModel>;
  final allProjects = [...firstProjects.items];
  for (var page = 2; page <= firstProjects.totalPages; page++) {
    allProjects
        .addAll((await repository.getFairProjects(fairId, page: page)).items);
  }

  final firstEvals = results[1] as PaginatedResult<JuryEvaluationSummaryModel>;
  final allEvals = [...firstEvals.items];
  for (var page = 2; page <= firstEvals.totalPages; page++) {
    allEvals.addAll(
      (await repository.getMyEvaluations(fairId: fairId, page: page, limit: 200))
          .items,
    );
  }

  return _calculateCategoryProgress(
    projects: allProjects.where((p) => p.status == 'APPROVED').toList(),
    evaluations: allEvals,
  );
});

/// Calcula el progreso de rúbricas por categoría combinando:
/// - Proyectos asignados (ya filtrados por categoría del jurado)
/// - Evaluaciones persistidas del jurado (submitted == true)
Map<String, CategoryRubricProgress> _calculateCategoryProgress({
  required List<FairProjectModel> projects,
  required List<JuryEvaluationSummaryModel> evaluations,
}) {
  // Map: projectId -> submitted (true solo si la evaluación está finalizada)
  final submittedByProject = <String, bool>{};
  for (final eval in evaluations) {
    if (eval.submitted) {
      submittedByProject[eval.projectId] = true;
    }
  }

  // Agrupar proyectos por categoryId
  final projectsByCategory = <String, List<FairProjectModel>>{};
  for (final project in projects) {
    final catId = project.categoryId;
    if (catId != null && catId.isNotEmpty) {
      projectsByCategory.putIfAbsent(catId, () => []).add(project);
    }
  }

  // Si no hay categorías, usar una sola "default"
  final categoryIds = projectsByCategory.keys.isEmpty
      ? ['default']
      : projectsByCategory.keys.toList();

  final progress = <String, CategoryRubricProgress>{};
  for (final catId in categoryIds) {
    final catProjects = projectsByCategory[catId] ?? const <FairProjectModel>[];
    final total = catProjects.length;
    final completed = catProjects
        .where((p) => submittedByProject[p.id] == true)
        .length;
    final pendingIds = catProjects
        .where((p) => submittedByProject[p.id] != true)
        .map((p) => p.id)
        .toList();
    progress[catId] = CategoryRubricProgress(
      categoryId: catId,
      totalProjects: total,
      completedRubrics: completed,
      pendingRubricProjectIds: pendingIds,
    );
  }
  return progress;
}
