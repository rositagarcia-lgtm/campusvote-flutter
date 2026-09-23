/// Hoja de respuestas de rúbrica del JURY para un proyecto.
///
/// Estructura:
///   RubricResponse
///     ├── fairId, projectId
///     ├── submitted (bool)        ← finalized
///     ├── submittedAt (DateTime?)
///     └── answers: `Map<criterionId, bool>`
///
/// Una rúbrica finalizada NO puede editarse.
class RubricResponse {
  final String fairId;
  final String projectId;
  final String rubricId;
  final bool submitted;
  final DateTime? submittedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Mapa criterionId → checked (true/false).
  /// El backend devuelve `responses[]` con entries `{criterion_id, checked}`.
  /// Normalizamos a un Map para lookup O(1) en la UI.
  final Map<String, bool> answers;

  const RubricResponse({
    required this.fairId,
    required this.projectId,
    required this.rubricId,
    required this.submitted,
    this.submittedAt,
    this.createdAt,
    this.updatedAt,
    required this.answers,
  });

  /// Crea una respuesta vacía (sin entries en BD aún) para inicializar la UI.
  factory RubricResponse.empty({
    required String fairId,
    required String projectId,
    required String rubricId,
  }) {
    return RubricResponse(
      fairId: fairId,
      projectId: projectId,
      rubricId: rubricId,
      submitted: false,
      submittedAt: null,
      answers: const {},
    );
  }

  /// Cantidad de criterios marcados (checked=true).
  int get checkedCount => answers.values.where((c) => c).length;
}
