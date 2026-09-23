import '../../../../core/config/endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/candidate_list.dart';
import '../../domain/entities/election.dart';
import '../../domain/entities/election_position.dart';
import '../../domain/repositories/voting_repository.dart';
import '../models/candidate_list_model.dart';
import '../models/election_model.dart';
import '../models/election_position_model.dart';
import 'voting_api_mapper.dart';

/// Capa de acceso a endpoints de elecciones + posiciones + listas + candidaturas.
class VotingElectionsAccess {
  VotingElectionsAccess(this._readClient);
  final dynamic Function() _readClient;

  Future<Result<PaginatedElections>> getAvailableElections({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final client = _readClient();
    try {
      final res = await client.get(
        ApiEndpoints.elections,
        query: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );
      // `data` es la LISTA de elecciones: forzarla a Map fallaba siempre, incluso
      // vacía ("List<dynamic> is not a subtype of Map<String, dynamic>").
      final r = VotingApiMapper.wrap<dynamic>(res.data, (raw) => raw);
      if (!r.success) {
        return FailureResult(VotingApiMapper.toFailure(r.error?.message));
      }
      final model = ElectionListModel.fromResponse(r.data ?? const [], r.meta);
      return Success(PaginatedElections(
        items: model.items.map((e) => e.toEntity()).toList(),
        total: model.total,
        page: model.page,
        totalPages: model.totalPages,
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<Election>> getElectionDetail(String electionId) async {
    final client = _readClient();
    try {
      final res = await client.get(ApiEndpoints.electionById(electionId));
      final r = VotingApiMapper.wrap<Map<String, dynamic>>(
        res.data,
        (raw) => raw as Map<String, dynamic>,
      );
      if (!r.success || r.data == null) {
        return FailureResult(VotingApiMapper.toFailure(r.error?.message));
      }
      return Success(ElectionModel.fromJson(r.data!).toEntity());
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<List<ElectionPosition>>> getElectionPositions(String id) async {
    final client = _readClient();
    try {
      final res = await client.get(ApiEndpoints.electionPositions(id));
      final r = VotingApiMapper.wrap<dynamic>(res.data, (raw) => raw);
      if (!r.success) {
        return FailureResult(VotingApiMapper.toFailure(r.error?.message));
      }
      final list = (r.data is List) ? r.data as List : const [];
      final models = list
          .whereType<Map>()
          .map((m) =>
              ElectionPositionModel.fromJson(Map<String, dynamic>.from(m)))
          .map((m) => m.toEntity())
          .toList();
      return Success(models);
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<List<CandidateList>>> getCandidateLists(String id) async {
    final client = _readClient();
    try {
      final res = await client.get(ApiEndpoints.electionCandidateLists(id));
      final r = VotingApiMapper.wrap<dynamic>(res.data, (raw) => raw);
      if (!r.success) {
        return FailureResult(VotingApiMapper.toFailure(r.error?.message));
      }
      final list = (r.data is List) ? r.data as List : const [];
      final models = list
          .whereType<Map>()
          .map((m) =>
              CandidateListModel.fromJson(Map<String, dynamic>.from(m)))
          .map((m) => m.toEntity())
          .toList();
      return Success(models);
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<List<Candidate>>> getCandidacies(
    String id, {
    String? positionId,
    String? listId,
  }) async {
    final client = _readClient();
    try {
      final res = await client.get(
        ApiEndpoints.electionCandidacies(id),
        query: {
          if (positionId != null) 'position_id': positionId,
          if (listId != null) 'candidate_list_id': listId,
        },
      );
      final r = VotingApiMapper.wrap<dynamic>(res.data, (raw) => raw);
      if (!r.success) {
        return FailureResult(VotingApiMapper.toFailure(r.error?.message));
      }
      final list = (r.data is List) ? r.data as List : const [];
      final models = list
          .whereType<Map>()
          .map((m) => CandidateModel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      return Success(models);
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }
}