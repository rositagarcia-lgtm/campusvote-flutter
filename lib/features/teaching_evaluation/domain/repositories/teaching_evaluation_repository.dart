import '../../../../core/errors/result.dart';
import '../entities/teacher_evaluation_form.dart';
import '../entities/teaching_assignment.dart';

abstract class TeachingEvaluationRepository {
  /// Asignaciones docentes del estudiante autenticado en el periodo activo.
  /// Cada asignación indica si ya fue evaluada (`evaluated`).
  Future<Result<List<TeachingAssignment>>> getMyAssignments();

  /// Criterios activos que aplican a la sede y carrera del curso.
  Future<Result<List<EvaluationCriterion>>> getCriteria({
    required String siteId,
    required String careerId,
  });

  /// Evaluación ya iniciada para la asignación, con sus puntajes; `null` si
  /// el alumno aún no empezó.
  Future<Result<EvaluationDraft?>> findDraft(String assignmentId);

  /// Inicia el borrador de la asignación.
  Future<Result<EvaluationDraft>> createDraft(String assignmentId);

  /// Guarda el puntaje (1-5) de un criterio en el borrador.
  Future<Result<void>> saveScore({
    required String responseId,
    required String criterionId,
    required int score,
  });

  /// Guarda el comentario (máx. 2000); vacío lo borra.
  Future<Result<void>> saveComment({
    required String responseId,
    required String comment,
  });

  /// Envía la evaluación. Exige todos los criterios calificados.
  Future<Result<void>> submit({
    required String responseId,
    required int overallRating,
  });
}
