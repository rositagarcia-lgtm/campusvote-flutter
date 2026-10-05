import 'package:dio/dio.dart';

import '../../../../core/config/endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../../domain/repositories/teaching_evaluation_repository.dart';
import '../models/teaching_assignment_model.dart';

class TeachingEvaluationRepositoryImpl implements TeachingEvaluationRepository {
  TeachingEvaluationRepositoryImpl(this._client);
  final ApiClient _client;

  @override
  Future<Result<List<TeachingAssignment>>> getMyAssignments() async {
    try {
      final res = await _client.get(ApiEndpoints.myTeachingAssignments);
      _throwForHttpError(res, ApiEndpoints.myTeachingAssignments);
      final raw = res.data;
      if (raw is Map && raw['success'] == false) {
        throw const FormatException('El servidor rechazó la consulta.');
      }
      final list = raw is Map
          ? raw['data']
          : raw is List
              ? raw
              : null;
      if (list is! List) {
        throw const FormatException(
          'El servidor devolvió una lista de asignaciones no válida.',
        );
      }
      final models = list
          .whereType<Map>()
          .map((m) =>
              TeachingAssignmentModel.fromJson(Map<String, dynamic>.from(m)))
          .map((m) => m.toEntity())
          .toList();
      return Success(models);
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<TeacherEvaluationResult>> evaluateTeacher({
    required String assignmentId,
    required int score,
    String? comment,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.evaluateTeacher,
        body: {
          'teaching_assignment_id': assignmentId,
          'score': score,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      _throwForHttpError(res, ApiEndpoints.evaluateTeacher);
      if (res.data is Map && (res.data as Map)['success'] == false) {
        throw const FormatException('El servidor no confirmó la evaluación.');
      }
      final responseBody = res.data;
      final rawData = responseBody is Map ? responseBody['data'] : null;
      if (rawData is! Map) {
        throw const FormatException(
          'El servidor no devolvió la confirmación de la evaluación.',
        );
      }
      final m = Map<String, dynamic>.from(rawData);
      return Success(TeacherEvaluationResult(
        id: (m['id'] ?? '').toString(),
        score: m['score'] is num ? (m['score'] as num).toInt() : score,
        submittedAt: m['created_at'] != null
            ? DateTime.tryParse(m['created_at'].toString())
            : null,
      ));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  void _throwForHttpError(Response<dynamic> response, String path) {
    final statusCode = response.statusCode ?? 500;
    if (statusCode < 400) return;
    throw DioException(
      requestOptions: RequestOptions(path: path),
      response: response,
      type: DioExceptionType.badResponse,
    );
  }
}
