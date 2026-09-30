import '../../data/models/jury_models.dart';

/// Contrato de dominio del panel de jurado.
///
/// `Future<T>` con errores: lanza [JuryApiException] (definido en el
/// datasource) para que cada provider lo traduzca a `AsyncError`.
abstract class JuryRepository {
  // Dashboard
  Future<PaginatedResult<FairAssignmentModel>> getMyAssignments({
    int page,
    int limit,
  });

  Future<JuryProgressModel> getMyProgress(String fairId);

  // Proyectos
  Future<PaginatedResult<FairProjectModel>> getFairProjects(
    String fairId, {
    int page,
    int limit,
    String? search,
  });

  // Rúbrica
  Future<RubricEvaluationModel> getProjectRubric(
      String fairId, String projectId);

  Future<RubricEvaluationModel> saveProjectRubric(
    String fairId,
    String projectId, {
    required Map<String, bool> answers,
    required bool finalize,
  });

  // Votación
  Future<VotingStatusModel> getVotingStatus(String fairId);

  Future<VoteReceiptModel> castVote(String fairId, String projectId);

  // Declaración
  Future<JuryDeclarationStatusModel> getDeclaration(String fairId);

  Future<JuryDeclarationModel> signDeclaration(String fairId, String statement);

  // Resultados y mis evaluaciones
  Future<FairResultsModel> getResults(String fairId);

  Future<PaginatedResult<JuryEvaluationSummaryModel>> getMyEvaluations({
    int page,
    int limit,
    String? fairId,
  });
}
