import 'package:dio/dio.dart';

import '../../../../core/config/endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/teacher_evaluation_form.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../../domain/repositories/teaching_evaluation_repository.dart';
import '../models/teaching_assignment_model.dart';

/// Evaluación docente por criterios (`/api/academic/evaluation-*`).
///
/// El alumno crea un borrador, guarda el puntaje de cada criterio y el
/// comentario, y al final lo envía con la calificación general.
class TeachingEvaluationRepositoryImpl implements TeachingEvaluationRepository {
  TeachingEvaluationRepositoryImpl(this._client);
  final ApiClient _client;

  @override
  Future<Result<List<TeachingAssignment>>> getMyAssignments() =>
      _guard(() async {
        final list = _list(await _send(
          ApiEndpoints.myTeachingAssignments,
          () => _client.get(ApiEndpoints.myTeachingAssignments),
        ));
        return list
            .map((m) => TeachingAssignmentModel.fromJson(m).toEntity())
            .toList();
      });

  @override
  Future<Result<List<EvaluationCriterion>>> getCriteria({
    required String siteId,
    required String careerId,
  }) =>
      _guard(() async {
        final list = _list(await _send(
          ApiEndpoints.evaluationCriteria,
          () => _client.get(ApiEndpoints.evaluationCriteria, query: {
            if (siteId.isNotEmpty) 'siteId': siteId,
            if (careerId.isNotEmpty) 'careerId': careerId,
          }),
        ));
        // El backend ya filtra activos para el alumno; se repite por seguridad.
        return list
            .where((m) => m['isActive'] != false)
            .map(criterionFromJson)
            .where((c) => c.id.isNotEmpty)
            .toList();
      });

  @override
  Future<Result<EvaluationDraft?>> findDraft(String assignmentId) =>
      _guard(() async {
        final mine = _list(await _send(
          ApiEndpoints.myEvaluationResponses,
          () => _client.get(ApiEndpoints.myEvaluationResponses),
        ));
        final match = mine
            .where((m) => m['teachingAssignmentId']?.toString() == assignmentId)
            .firstOrNull;
        final id = match?['id']?.toString() ?? '';
        if (id.isEmpty) return null;
        // La lista no trae los puntajes: se piden al detalle.
        final path = ApiEndpoints.evaluationResponse(id);
        return draftFromJson(
            _object(await _send(path, () => _client.get(path))));
      });

  @override
  Future<Result<EvaluationDraft>> createDraft(String assignmentId) =>
      _guard(() async {
        final data = _object(await _send(
          ApiEndpoints.evaluationResponses,
          () => _client.post(ApiEndpoints.evaluationResponses,
              body: {'teachingAssignmentId': assignmentId}),
        ));
        final draft = draftFromJson(data);
        if (draft.id.isEmpty) {
          throw const FormatException('El servidor no devolvió el borrador.');
        }
        return draft;
      });

  @override
  Future<Result<void>> saveScore({
    required String responseId,
    required String criterionId,
    required int score,
  }) =>
      _guard(() async {
        final path =
            ApiEndpoints.evaluationResponseDetail(responseId, criterionId);
        await _send(path, () => _client.put(path, body: {'score': score}));
      });

  @override
  Future<Result<void>> saveComment({
    required String responseId,
    required String comment,
  }) =>
      _guard(() async {
        final path = ApiEndpoints.evaluationResponseComment(responseId);
        final trimmed = comment.trim();
        await _send(
          path,
          () => _client
              .patch(path, body: {'comment': trimmed.isEmpty ? null : trimmed}),
        );
      });

  @override
  Future<Result<void>> submit({
    required String responseId,
    required int overallRating,
  }) =>
      _guard(() async {
        final path = ApiEndpoints.evaluationResponseSubmit(responseId);
        await _send(path,
            () => _client.post(path, body: {'overall_rating': overallRating}));
      });

  // ── Utilidades ──

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  /// Ejecuta la petición y lanza si el estado HTTP o `success` indican error.
  Future<Object?> _send(
    String path,
    Future<Response<dynamic>> Function() request,
  ) async {
    final response = await request();
    final statusCode = response.statusCode ?? 500;
    if (statusCode >= 400) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    final body = response.data;
    if (body is Map && body['success'] == false) {
      throw const FormatException('El servidor rechazó la solicitud.');
    }
    return body is Map ? body['data'] : body;
  }

  List<Map<String, dynamic>> _list(Object? data) {
    if (data is! List) {
      throw const FormatException('El servidor devolvió una lista no válida.');
    }
    return data
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  Map<String, dynamic> _object(Object? data) {
    if (data is! Map) {
      throw const FormatException(
          'El servidor devolvió una respuesta no válida.');
    }
    return Map<String, dynamic>.from(data);
  }
}
