/// Rúbrica de evaluación CHECKLIST de una feria.
///
/// Estructura:
///   FairRubric
///     ├── id, fairId, name, description
///     └── criteria: `List<FairRubricCriterion>`
///
/// La rúbrica es UNA por feria (configurada por el ADMIN).
/// Los criterios ACTIVOS son los que el JURY debe marcar.
///
/// IMPORTANTE: la rúbrica NO determina al ganador.
/// Solo es evaluación académica mediante checklist booleano.
class FairRubric {
  final String id;
  final String fairId;
  final String name;
  final String? description;
  final List<FairRubricCriterion> criteria;

  const FairRubric({
    required this.id,
    required this.fairId,
    required this.name,
    this.description,
    required this.criteria,
  });

  /// Criterios ACTIVOS que el JURY debe responder.
  List<FairRubricCriterion> get activeCriteria =>
      criteria.where((c) => c.isActive).toList(growable: false);
}

class FairRubricCriterion {
  final String id;
  final String name;
  final String? description;
  final int position;
  final bool isActive;

  const FairRubricCriterion({
    required this.id,
    required this.name,
    this.description,
    required this.position,
    required this.isActive,
  });
}
