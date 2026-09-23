import '../../../../core/errors/result.dart';
import '../entities/fair_assignment.dart';
import '../entities/fair_project.dart';
import '../entities/fair_rubric.dart';
import '../entities/rubric_response.dart';
import '../entities/voting_state.dart';
import '../repositories/fair_voting_repository.dart';

// ── Asignaciones ─────────────────────────────────────────────────────

class GetMyAssignedFairsUseCase {
  GetMyAssignedFairsUseCase(this._repo);
  final FairVotingRepository _repo;
  Future<Result<PaginatedFairAssignments>> call({
    int page = 1,
    int limit = 50,
  }) =>
      _repo.getMyAssignedFairs(page: page, limit: limit);
}

class GetMyAssignedFairDetailUseCase {
  GetMyAssignedFairDetailUseCase(this._repo);
  final FairVotingRepository _repo;
  Future<Result<FairAssignment>> call(String fairId) =>
      _repo.getMyAssignedFairDetail(fairId);
}

// ── Proyectos ────────────────────────────────────────────────────────

class GetFairProjectsUseCase {
  GetFairProjectsUseCase(this._repo);
  final FairVotingRepository _repo;
  Future<Result<PaginatedFairProjects>> call(String fairId, {String? status}) =>
      _repo.getFairProjects(fairId, status: status);
}

class GetFairProjectDetailUseCase {
  GetFairProjectDetailUseCase(this._repo);
  final FairVotingRepository _repo;
  Future<Result<FairProject>> call(String projectId) =>
      _repo.getFairProjectDetail(projectId);
}

// ── Rúbrica ──────────────────────────────────────────────────────────

class GetFairRubricUseCase {
  GetFairRubricUseCase(this._repo);
  final FairVotingRepository _repo;
  Future<Result<FairRubric>> call(String fairId) => _repo.getFairRubric(fairId);
}

class GetMyRubricResponseUseCase {
  GetMyRubricResponseUseCase(this._repo);
  final FairVotingRepository _repo;
  Future<Result<RubricResponse>> call({
    required String fairId,
    required String projectId,
  }) =>
      _repo.getMyRubricResponse(fairId: fairId, projectId: projectId);
}

class SaveMyRubricResponseUseCase {
  SaveMyRubricResponseUseCase(this._repo);
  final FairVotingRepository _repo;

  /// `finalize=true` cierra la hoja y bloquea ediciones posteriores.
  /// El backend valida que todos los criterios ACTIVOS estén respondidos
  /// antes de permitir la finalización.
  Future<Result<RubricResponse>> call({
    required String fairId,
    required String projectId,
    required Map<String, bool> answers,
    required bool finalize,
  }) =>
      _repo.saveMyRubricResponse(
        fairId: fairId,
        projectId: projectId,
        answers: answers,
        finalize: finalize,
      );
}

// ── Votación ─────────────────────────────────────────────────────────

class GetVotingStatusUseCase {
  GetVotingStatusUseCase(this._repo);
  final FairVotingRepository _repo;
  Future<Result<VotingState>> call(String fairId) =>
      _repo.getVotingStatus(fairId);
}

class CastVoteUseCase {
  CastVoteUseCase(this._repo);
  final FairVotingRepository _repo;

  /// Solo se envía `projectId`. El backend obtiene el `juryUserId`
  /// desde la sesión autenticada.
  Future<Result<CastVoteReceipt>> call({
    required String fairId,
    required String projectId,
  }) =>
      _repo.castVote(fairId: fairId, projectId: projectId);
}
