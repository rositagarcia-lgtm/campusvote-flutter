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
      final raw = res.data;
      final list = raw is Map
          ? (raw['data'] is List ? raw['data'] : <dynamic>[])
          : (raw is List ? raw : <dynamic>[]);
      final models = list
          .whereType<Map>()
          .map((m) => TeachingAssignmentModel.fromJson(Map<String, dynamic>.from(m)))
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
      final m = res.data is Map
          ? Map<String, dynamic>.from((res.data as Map)['data'] as Map? ?? const {})
          : const <String, dynamic>{};
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
}