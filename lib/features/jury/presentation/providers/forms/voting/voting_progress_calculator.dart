// voting_progress_calculator.dart

import '../../../../data/models/jury_models.dart';
import '../../../state/jury_state.dart'
    show CategoryRubricProgress;

/// Calcula el progreso de rúbricas por categoría combinando:
/// - Proyectos asignados (ya filtrados por categoría del jurado)
/// - Evaluaciones persistidas del jurado (submitted == true)
Map<String, CategoryRubricProgress> calculateCategoryProgress({
  required List<FairProjectModel> projects,
  required List<JuryEvaluationSummaryModel> evaluations,
  required List<VotingCategory> categories,
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

  // Si el backend no envía categorías en voting status, usar una sola "default"
  final categoryIds = categories.isEmpty
      ? (projectsByCategory.keys.isEmpty ? ['default'] : projectsByCategory.keys.toList())
      : categories.map((c) => c.id).toList();

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

/// Extrae puntajes de las rúbricas finalizadas por este jurado en la feria.
Map<String, double> extractMyScores(List<JuryEvaluationSummaryModel> evals) {
  return {
    for (final e in evals)
      if (e.submitted && e.score != null) e.projectId: e.score!,
  };
}