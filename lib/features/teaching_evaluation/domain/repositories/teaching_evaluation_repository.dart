import '../../../../core/errors/result.dart';
import '../entities/teaching_assignment.dart';

abstract class TeachingEvaluationRepository {
  /// Asignaciones docentes del estudiante autenticado (carrera/ciclo/periodo).
  /// Cada asignación indica si ya fue evaluada (`evaluated`).
  Future<Result<List<TeachingAssignment>>> getMyAssignments();

  /// Registra la evaluación del estudiante para una asignación.
  /// `score` debe estar entre 1 y 5; `comment` es opcional (máx. 2000).
  Future<Result<TeacherEvaluationResult>> evaluateTeacher({
    required String assignmentId,
    required int score,
    String? comment,
  });
}