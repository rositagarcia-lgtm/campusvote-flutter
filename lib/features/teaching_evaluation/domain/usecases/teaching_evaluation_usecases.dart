import '../../../../core/errors/result.dart';
import '../entities/teaching_assignment.dart';
import '../repositories/teaching_evaluation_repository.dart';

/// Lista las asignaciones docentes del estudiante autenticado.
class GetMyTeachingAssignmentsUseCase {
  GetMyTeachingAssignmentsUseCase(this._repo);
  final TeachingEvaluationRepository _repo;

  Future<Result<List<TeachingAssignment>>> call() => _repo.getMyAssignments();
}

/// Envía la evaluación validando antes la calificación general.
class SubmitTeacherEvaluationUseCase {
  SubmitTeacherEvaluationUseCase(this._repo);
  final TeachingEvaluationRepository _repo;

  Future<Result<void>> call({
    required String responseId,
    required int overallRating,
  }) {
    if (overallRating < 1 || overallRating > 5) {
      return Future.value(
        const FailureResult(
          ValidationFailure(
            message: 'La calificación general debe estar entre 1 y 5 estrellas',
          ),
        ),
      );
    }
    return _repo.submit(responseId: responseId, overallRating: overallRating);
  }
}
