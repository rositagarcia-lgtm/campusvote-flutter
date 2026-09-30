import '../../domain/repositories/jury_repository.dart';
import '../datasources/jury_remote_datasource.dart';
import '../models/jury_models.dart';

/// Traduce el envelope `{ data, meta.pagination }` a entidades de dominio.
class JuryRepositoryImpl implements JuryRepository {
  JuryRepositoryImpl(this._remote);

  final JuryRemoteDataSource _remote;

  /// El backend responde `{ success, data: {...} }` para un objeto y
  /// `{ success, data: [...], meta }` para listas; en ambos casos el modelo
  /// se parsea desde `data`.
  Map<String, dynamic> _object(Map<String, dynamic> body) {
    final data = body['data'];
    return data is Map ? Map<String, dynamic>.from(data) : body;
  }

  @override
  Future<PaginatedResult<FairAssignmentModel>> getMyAssignments({
    int page = 1,
    int limit = 50,
  }) async {
    final body = await _remote.getMyAssignments(page: page, limit: limit);
    return PaginatedResult<FairAssignmentModel>.fromEnvelope(
      body,
      FairAssignmentModel.fromJson,
    );
  }

  @override
  Future<JuryProgressModel> getMyProgress(String fairId) async {
    final body = await _remote.getMyProgress(fairId);
    return JuryProgressModel.fromJson(_object(body));
  }

  @override
  Future<PaginatedResult<FairProjectModel>> getFairProjects(
    String fairId, {
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    final body = await _remote.getFairProjects(
      fairId,
      page: page,
      limit: limit,
      search: search,
    );
    return PaginatedResult<FairProjectModel>.fromEnvelope(
      body,
      FairProjectModel.fromJson,
    );
  }

  @override
  Future<RubricEvaluationModel> getProjectRubric(
    String fairId,
    String projectId,
  ) async {
    final body = await _remote.getProjectRubric(fairId, projectId);
    return RubricEvaluationModel.fromJson(_object(body));
  }

  @override
  Future<RubricEvaluationModel> saveProjectRubric(
    String fairId,
    String projectId, {
    required Map<String, bool> answers,
    required bool finalize,
  }) async {
    // Solo `criterion_id` + `checked`: el schema es `.strict()`.
    final body = await _remote.saveProjectRubric(
      fairId,
      projectId,
      responses: [
        for (final entry in answers.entries)
          {'criterion_id': entry.key, 'checked': entry.value},
      ],
      finalize: finalize,
    );
    return RubricEvaluationModel.fromJson(_object(body));
  }

  @override
  Future<VotingStatusModel> getVotingStatus(String fairId) async {
    final body = await _remote.getVotingStatus(fairId);
    return VotingStatusModel.fromJson(_object(body));
  }

  @override
  Future<VoteReceiptModel> castVote(String fairId, String projectId) async {
    final body = await _remote.castVote(fairId, projectId);
    return VoteReceiptModel.fromJson(_object(body));
  }

  @override
  Future<JuryDeclarationStatusModel> getDeclaration(String fairId) async {
    final body = await _remote.getDeclaration(fairId);
    return JuryDeclarationStatusModel.fromJson(_object(body));
  }

  @override
  Future<JuryDeclarationModel> signDeclaration(
    String fairId,
    String statement,
  ) async {
    final body = await _remote.signDeclaration(fairId, statement);
    return JuryDeclarationModel.fromJson(_object(body));
  }

  @override
  Future<FairResultsModel> getResults(String fairId) async {
    final body = await _remote.getResults(fairId);
    return FairResultsModel.fromJson(_object(body));
  }

  @override
  Future<PaginatedResult<JuryEvaluationSummaryModel>> getMyEvaluations({
    int page = 1,
    int limit = 50,
    String? fairId,
  }) async {
    final body = await _remote.getMyEvaluations(
      page: page,
      limit: limit,
      fairId: fairId,
    );
    return PaginatedResult<JuryEvaluationSummaryModel>.fromEnvelope(
      body,
      JuryEvaluationSummaryModel.fromJson,
    );
  }
}
