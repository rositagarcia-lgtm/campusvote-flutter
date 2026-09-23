import '../../../../core/config/endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/fair_assignment.dart';
import '../../domain/entities/fair_project.dart';
import '../../domain/entities/fair_rubric.dart';
import '../../domain/entities/rubric_response.dart';
import '../../domain/entities/voting_state.dart';
import '../../domain/repositories/fair_voting_repository.dart';
import '../models/fair_assignment_model.dart';
import '../models/fair_project_model.dart';
import '../models/fair_rubric_model.dart';
import '../models/rubric_response_model.dart';

class FairVotingRepositoryImpl implements FairVotingRepository {
  FairVotingRepositoryImpl(this._client);
  final ApiClient _client;

  ApiResponse<Map<String, dynamic>> _wrapMap(dynamic raw) {
    if (raw is! Map) {
      return const ApiResponse<Map<String, dynamic>>(success: false);
    }
    return ApiResponse<Map<String, dynamic>>.fromJson(
      Map<String, dynamic>.from(raw),
      (d) => Map<String, dynamic>.from(d as Map),
    );
  }

  ApiResponse<dynamic> _wrapList(dynamic raw) {
    if (raw is! Map) return const ApiResponse<dynamic>(success: false);
    return ApiResponse<dynamic>.fromJson(
      Map<String, dynamic>.from(raw),
      (d) => d,
    );
  }

  Failure _failure(ApiResponse<dynamic> r) =>
      UnknownFailure(message: r.error?.message ?? r.message ?? 'Error');

  // ── Asignaciones ─────────────────────────────────────────────────────

  @override
  Future<Result<PaginatedFairAssignments>> getMyAssignedFairs({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.myJuryAssignments,
        query: {'page': page, 'limit': limit},
      );
      // `data` es la LISTA de asignaciones: con _wrapMap el cast a Map fallaba
      // ("List<dynamic> is not a subtype of Map<String, dynamic>").
      final r = _wrapList(res.data);
      if (!r.success) return FailureResult(_failure(r));
      final model = FairAssignmentListModel.fromResponse(
        data: r.data ?? res.data,
        meta: r.meta,
      );
      return Success(PaginatedFairAssignments(
        items: model.itemsRaw
            .map((m) => FairAssignmentModel.fromJson(m).toEntity())
            .toList(),
        total: model.total,
        page: model.page,
        totalPages: model.limit == 0
            ? 1
            : ((model.total + model.limit - 1) ~/ model.limit),
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<FairAssignment>> getMyAssignedFairDetail(String fairId) async {
    try {
      final res = await _client.get(ApiEndpoints.myJuryAssignmentDetail(fairId));
      final r = _wrapMap(res.data);
      if (!r.success) return FailureResult(_failure(r));
      return Success(
        FairAssignmentModel.fromJson(r.data ?? const {}).toEntity(),
      );
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  // ── Proyectos ───────────────────────────────────────────────────────

  @override
  Future<Result<PaginatedFairProjects>> getFairProjects(
    String fairId, {
    String? status,
  }) async {
    try {
      // Ruta del jurado: solo proyectos aprobados de SUS categorías. Por
      // /api/projects vería todos y no podría evaluar los de otras categorías.
      final res = await _client.get(
        ApiEndpoints.fairProjects(fairId),
        query: {'limit': 100},
      );
      final r = _wrapList(res.data);
      if (!r.success) {
        return FailureResult(
          UnknownFailure(message: r.error?.message ?? r.message ?? 'Error'),
        );
      }
      final model = FairProjectListModel.fromResponse(
        data: (r.data is Map && r.data['data'] is List) ? r.data : res.data,
        meta: r.meta,
      );
      return Success(PaginatedFairProjects(
        items: model.items.map((m) => m.toEntity()).toList(),
        total: model.total,
        page: model.page,
        totalPages: model.limit == 0
            ? 1
            : ((model.total + model.limit - 1) ~/ model.limit),
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<FairProject>> getFairProjectDetail(String projectId) async {
    try {
      final res = await _client.get(ApiEndpoints.projectById(projectId));
      final r = _wrapMap(res.data);
      if (!r.success) return FailureResult(_failure(r));
      return Success(
        FairProjectModel.fromJson(r.data ?? const {}).toEntity(),
      );
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  // ── Rúbrica ────────────────────────────────────────────────────────

  @override
  Future<Result<FairRubric>> getFairRubric(String fairId) async {
    try {
      final res = await _client.get(ApiEndpoints.fairRubric(fairId));
      final r = _wrapMap(res.data);
      if (!r.success) return FailureResult(_failure(r));
      return Success(
        FairRubricModel.fromJson(r.data ?? const {}),
      );
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<RubricResponse>> getMyRubricResponse({
    required String fairId,
    required String projectId,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.fairProjectRubric(fairId, projectId),
      );
      final r = _wrapMap(res.data);
      if (!r.success) return FailureResult(_failure(r));

      // Si no existe hoja aún (no debería ser 404 si success=true), se devuelve
      // una hoja vacía para que la UI pueda inicializar el formulario.
      if (r.data == null) {
        // Necesitamos saber el rubricId. Lo pedimos aparte.
        return await _emptyResponseFor(fairId, projectId);
      }
      return Success(RubricResponseModel.fromJson(r.data!).toEntity());
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<RubricResponse>> _emptyResponseFor(String fairId, String projectId) async {
    final rubricRes = await getFairRubric(fairId);
    return rubricRes.when(
      success: (rubric) => Success(RubricResponse.empty(
        fairId: fairId,
        projectId: projectId,
        rubricId: rubric.id,
      )),
      failure: (f) => FailureResult(f),
    );
  }

  @override
  Future<Result<RubricResponse>> saveMyRubricResponse({
    required String fairId,
    required String projectId,
    required Map<String, bool> answers,
    required bool finalize,
  }) async {
    try {
      // Construimos el payload en el formato exacto del backend:
      //   { responses: [{ criterion_id, checked }], finalize: bool }
      final payload = {
        'responses': [
          for (final entry in answers.entries)
            {'criterion_id': entry.key, 'checked': entry.value},
        ],
        'finalize': finalize,
      };
      final res = await _client.put(
        ApiEndpoints.fairProjectRubric(fairId, projectId),
        body: payload,
      );
      final r = _wrapMap(res.data);
      if (!r.success) return FailureResult(_failure(r));
      return Success(RubricResponseModel.fromJson(r.data ?? const {}).toEntity());
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  // ── Votación ────────────────────────────────────────────────────────

  @override
  Future<Result<VotingState>> getVotingStatus(String fairId) async {
    try {
      final res = await _client.get(ApiEndpoints.fairVotingStatus(fairId));
      final r = _wrapMap(res.data);
      if (!r.success) return FailureResult(_failure(r));
      final m = r.data ?? const {};
      return Success(VotingState(
        fairId: (m['fair_id'] ?? m['fairId'] ?? fairId).toString(),
        fairStatus: (m['fair_status'] ?? m['fairStatus'] ?? '').toString(),
        hasVoted: (m['has_voted'] ?? m['hasVoted'] ?? false) == true,
        votedAt: _parseDate(m['voted_at'] ?? m['votedAt']),
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<CastVoteReceipt>> castVote({
    required String fairId,
    required String projectId,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.fairVotingCast(fairId),
        body: {'project_id': projectId},
      );
      final r = _wrapMap(res.data);
      if (!r.success) return FailureResult(_failure(r));
      final m = r.data ?? const {};
      return Success(CastVoteReceipt(
        status: (m['status'] ?? 'CAST').toString(),
        receiptCode: (m['receipt_code'] ?? m['receiptCode'] ?? '').toString(),
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
