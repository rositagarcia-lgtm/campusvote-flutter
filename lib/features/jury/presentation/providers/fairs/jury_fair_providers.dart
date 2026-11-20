// fairs/jury_fair_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/presentation/state/auth_controller.dart';
import '../../../data/models/jury_models.dart';
import '../data/jury_dependencies.dart';
import '../jury_state.dart';


/// `GET /fairs/my-assignments`
final juryDashboardProvider =
    AsyncNotifierProvider<JuryDashboardNotifier, List<FairAssignmentModel>>(
        JuryDashboardNotifier.new);

class JuryDashboardNotifier extends AsyncNotifier<List<FairAssignmentModel>> {
  Future<List<FairAssignmentModel>> _loadAll() async {
    if (!ref.read(authControllerProvider).authenticated) {
      return const [];
    }
    final repository = ref.read(juryRepositoryProvider);
    final first = await repository.getMyAssignments();
    final assignments = [...first.items];
    for (var page = 2; page <= first.totalPages; page++) {
      assignments.addAll((await repository.getMyAssignments(page: page)).items);
    }
    return assignments;
  }

  @override
  Future<List<FairAssignmentModel>> build() => _loadAll();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadAll);
  }
}

/// AsignaciÃ³n (fase y fechas) de una feria, tomada de `my-assignments`.
/// Nulo mientras carga: las pantallas no asumen vista previa sin saberlo.
final juryFairAssignmentProvider =
    Provider.family<FairAssignmentModel?, String>((ref, fairId) => ref
        .watch(juryDashboardProvider)
        .valueOrNull
        ?.where((fair) => fair.fairId == fairId)
        .firstOrNull);

/// Vista previa: el jurado estudia, pero aÃºn no evalÃºa, vota ni reseÃ±a.
final juryFairInPreviewProvider = Provider.family<bool, String>((ref, fairId) =>
    ref.watch(juryFairAssignmentProvider(fairId))?.phase == JuryPhase.preview);


/// `GET /fairs/:fairId/projects` â€” NO se re-filtra en Flutter (regla 7).
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

// â”€â”€ Mis evaluaciones â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

// â”€â”€ Progreso de rÃºbricas por categorÃ­a (para habilitar votaciÃ³n) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Progreso de rÃºbricas por categorÃ­a para una feria.
/// Reutiliza `fairProjectsProvider` y `myEvaluationsProvider` (sin `limit: 200`)
/// para evitar errores 400 de paginaciÃ³n y mantener sincronizado el banner,
/// el botÃ³n de votaciÃ³n y las tarjetas de proyectos.
final categoryRubricProgressProvider =
    FutureProvider.family<Map<String, CategoryRubricProgress>, String>(
        (ref, fairId) async {
  final allProjects = await ref.watch(fairProjectsProvider(fairId).future);
  final allEvals = await ref.watch(myEvaluationsProvider(fairId).future);

  return _calculateCategoryProgress(
    projects: allProjects.where((p) => p.status == 'APPROVED').toList(),
    evaluations: allEvals,
  );
});

/// Calcula el progreso de rÃºbricas por categorÃ­a combinando:
/// - Proyectos asignados (ya filtrados por categorÃ­a del jurado)
/// - Evaluaciones persistidas del jurado (solo `submitted == true` cuenta como completa)
Map<String, CategoryRubricProgress> _calculateCategoryProgress({
  required List<FairProjectModel> projects,
  required List<JuryEvaluationSummaryModel> evaluations,
}) {
  final submittedByProject = <String, bool>{};
  final draftByProject = <String, bool>{};
  for (final eval in evaluations) {
    if (eval.submitted) {
      submittedByProject[eval.projectId] = true;
    } else {
      draftByProject[eval.projectId] = true;
    }
  }

  final projectsByCategory = <String, List<FairProjectModel>>{};
  final categoryNames = <String, String>{};
  for (final project in projects) {
    final catId = project.categoryId;
    if (catId != null && catId.isNotEmpty) {
      projectsByCategory.putIfAbsent(catId, () => []).add(project);
      if (project.categoryName != null && project.categoryName!.isNotEmpty) {
        categoryNames[catId] = project.categoryName!;
      }
    }
  }

  final categoryIds = projectsByCategory.keys.isEmpty
      ? ['default']
      : projectsByCategory.keys.toList();

  final progress = <String, CategoryRubricProgress>{};
  for (final catId in categoryIds) {
    final catProjects = projectsByCategory[catId] ?? const <FairProjectModel>[];
    final total = catProjects.length;
    final completed =
        catProjects.where((p) => submittedByProject[p.id] == true).length;
    final drafts = catProjects
        .where((p) =>
            submittedByProject[p.id] != true && draftByProject[p.id] == true)
        .length;
    final pendingIds = catProjects
        .where((p) => submittedByProject[p.id] != true)
        .map((p) => p.id)
        .toList();
    progress[catId] = CategoryRubricProgress(
      categoryId: catId,
      categoryName: categoryNames[catId],
      totalProjects: total,
      completedRubrics: completed,
      draftCount: drafts,
      pendingRubricProjectIds: pendingIds,
    );
  }
  return progress;
}
