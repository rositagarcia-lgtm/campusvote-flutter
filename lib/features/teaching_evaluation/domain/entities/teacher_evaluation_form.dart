/// Criterio de la rúbrica docente (de la sede, de la carrera o general).
class EvaluationCriterion {
  final String id;
  final String name;
  final String? description;

  /// `null` = criterio general de la sede (aplica a todas sus carreras).
  final String? careerId;

  const EvaluationCriterion({
    required this.id,
    required this.name,
    this.description,
    this.careerId,
  });

  bool get isGeneral => careerId == null;
}

/// Evaluación del alumno para una asignación. Se guarda como borrador mientras
/// califica cada criterio y se envía una sola vez.
class EvaluationDraft {
  final String id;
  final bool submitted;

  /// Puntaje (1-5) por id de criterio.
  final Map<String, int> scores;
  final String? comment;

  const EvaluationDraft({
    required this.id,
    this.submitted = false,
    this.scores = const {},
    this.comment,
  });
}
