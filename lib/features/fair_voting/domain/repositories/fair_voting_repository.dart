import '../../../../core/errors/result.dart';
import '../entities/fair_assignment.dart';
import '../entities/fair_project.dart';
import '../entities/fair_rubric.dart';
import '../entities/rubric_response.dart';
import '../entities/voting_state.dart';

abstract class FairVotingRepository {
  /// Ferias asignadas al JURY autenticado.
  Future<Result<PaginatedFairAssignments>> getMyAssignedFairs({
    int page = 1,
    int limit = 50,
  });

  Future<Result<FairAssignment>> getMyAssignedFairDetail(String fairId);

  /// Proyectos APPROVED de una feria (filtrable por estado).
  Future<Result<PaginatedFairProjects>> getFairProjects(
    String fairId, {
    String? status,
  });

  /// Detalle de un proyecto (incluye miembros, categoría, stand).
  Future<Result<FairProject>> getFairProjectDetail(String projectId);

  /// Rúbrica configurada para una feria (criterios a marcar).
  Future<Result<FairRubric>> getFairRubric(String fairId);

  /// Hoja de respuestas del JURY para un proyecto (puede no existir aún).
  /// Devuelve `RubricResponse.empty(...)` cuando el backend devuelve 404.
  Future<Result<RubricResponse>> getMyRubricResponse({
    required String fairId,
    required String projectId,
  });

  /// Guarda (upsert) las respuestas del JURY.
  /// `finalize=true` cierra la hoja y bloquea ediciones posteriores.
  Future<Result<RubricResponse>> saveMyRubricResponse({
    required String fairId,
    required String projectId,
    required Map<String, bool> answers,
    required bool finalize,
  });

  /// Estado de votación del JURY en una feria (SIN proyecto elegido).
  Future<Result<VotingState>> getVotingStatus(String fairId);

  /// Emite el voto del JURY. Devuelve comprobante anónimo.
  Future<Result<CastVoteReceipt>> castVote({
    required String fairId,
    required String projectId,
  });
}
