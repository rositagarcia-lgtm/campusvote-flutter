// fair_project_filter.dart

import '../../data/models/jury_models.dart';

/// Filtros locales de la lista de proyectos.
///
/// El estado real de una rúbrica lo dice la API (`submitted`); este enum solo
/// agrupa la lista ya traída, sin volver a preguntar al backend.
enum FairProjectFilter {
  all('Todos'),
  pending('Pendientes'),
  completed('Evaluados');

  const FairProjectFilter(this.label);

  /// Etiqueta del filtro, corta para la barra segmentada.
  final String label;
}

/// Qué proyectos entran en cada filtro.
///
/// `submittedIds` sale de `myEvaluationsProvider`; mientras ese endpoint no ha
/// respondido, la lista se muestra completa en vez de ocultarse.
List<FairProjectModel> filterFairProjects({
  required List<FairProjectModel> projects,
  required FairProjectFilter filter,
  required Set<String> submittedIds,
}) {
  if (filter == FairProjectFilter.all) return projects;
  final keep = filter == FairProjectFilter.completed;
  return projects
      .where((project) => submittedIds.contains(project.id) == keep)
      .toList(growable: false);
}

/// Proyectos ya evaluados según [submittedIds].
int countEvaluatedProjects({
  required List<FairProjectModel> projects,
  required Set<String> submittedIds,
}) =>
    projects.where((project) => submittedIds.contains(project.id)).length;

/// Nombre de la feria a la que pertenece [fairId].
///
/// El backend devuelve las asignaciones del jurado, así que el nombre sale de
/// ahí y no de un texto fijo en la interfaz. Devuelve `null` si la asignación
/// aún no ha llegado, para que la cabecera pueda mostrar su texto por defecto.
String? fairNameForFairId({
  required Iterable<FairAssignmentModel> assignments,
  required String fairId,
}) {
  for (final assignment in assignments) {
    if (assignment.fairId == fairId) return assignment.name;
  }
  return null;
}