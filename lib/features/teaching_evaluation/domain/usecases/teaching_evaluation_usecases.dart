import '../../../../core/errors/result.dart';
import '../entities/teaching_assignment.dart';
import '../repositories/teaching_evaluation_repository.dart';

/// Lista las asignaciones docentes del estudiante autenticado.
class GetMyTeachingAssignmentsUseCase {
  GetMyTeachingAssignmentsUseCase(this._repo);
  final TeachingEvaluationRepository _repo;

  Future<Result<List<TeachingAssignment>>> call() => _repo.getMyAssignments();
}

/// Registra la evaluación (1-5 + comentario opcional) de una asignación.
class EvaluateTeacherUseCase {
  EvaluateTeacherUseCase(this._repo);
  final TeachingEvaluationRepository _repo;

  Future<Result<TeacherEvaluationResult>> call({
    required String assignmentId,
    required int score,
    String? comment,
  }) {
    if (score < 1 || score > 5) {
      return Future.value(
        const FailureResult(
          ValidationFailure(
            message: 'La calificación debe estar entre 1 y 5 estrellas',
          ),
        ),
      );
    }
    final trimmed = comment?.trim();
    final c = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    if (c != null && c.length > 2000) {
      return Future.value(
        const FailureResult(
          ValidationFailure(
            message: 'El comentario no puede superar los 2000 caracteres',
          ),
        ),
      );
    }
    return _repo.evaluateTeacher(
      assignmentId: assignmentId,
      score: score,
      comment: c,
    );
  }
}