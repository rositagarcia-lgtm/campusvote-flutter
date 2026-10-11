import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/network/api_client.dart';
import '../../auth/domain/entities/auth_role.dart';
import '../../auth/presentation/state/auth_controller.dart';
import '../domain/audience_models.dart';

/// Opinión del público: el alumno califica y comenta proyectos de feria.
/// No es jurado: su voto no suma a la nota ni al resultado oficial.
class FairAudienceRepository {
  FairAudienceRepository(this._client);
  final ApiClient _client;

  Future<List<AudienceFair>> fairs() async {
    final data = await _get(ApiEndpoints.audienceFairs);
    return [
      for (final f in data is List ? data : const [])
        if (f is Map) AudienceFair.fromJson(Map<String, dynamic>.from(f)),
    ];
  }

  Future<AudienceBoard> board(String fairId) async {
    final data = await _get(ApiEndpoints.audienceProjects(fairId));
    if (data is! Map) throw const FormatException('Feria no válida.');
    return AudienceBoard.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> rate({
    required String fairId,
    required String projectId,
    required int score,
    String? comment,
  }) async {
    final path = ApiEndpoints.audienceRating(fairId, projectId);
    final trimmed = comment?.trim() ?? '';
    _check(
      await _client.put(path, body: {
        'score': score,
        'comment': trimmed.isEmpty ? null : trimmed,
      }),
      path,
    );
  }

  Future<PeerFeedback> feedback(String fairId, String projectId) async {
    final data = await _get(ApiEndpoints.audienceFeedback(fairId, projectId));
    if (data is! Map) throw const FormatException('Opiniones no válidas.');
    return PeerFeedback.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Object?> _get(String path) async {
    final body = _check(await _client.get(path), path);
    return body is Map ? body['data'] : body;
  }

  Object? _check(Response<dynamic> response, String path) {
    if ((response.statusCode ?? 500) >= 400) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    return response.data;
  }
}

final fairAudienceRepositoryProvider = Provider<FairAudienceRepository>(
  (ref) => FairAudienceRepository(ref.watch(apiClientProvider)),
);

bool _isStudent(Ref ref) => ref.watch(authControllerProvider
    .select((s) => s.authenticated && s.user?.role == AuthRole.student));

/// Ferias abiertas o cerradas de la organización del alumno.
final audienceFairsProvider =
    FutureProvider.autoDispose<List<AudienceFair>>((ref) async {
  if (!_isStudent(ref)) return const [];
  return ref.watch(fairAudienceRepositoryProvider).fairs();
});

/// Proyectos de una feria con el voto propio.
final audienceBoardProvider = FutureProvider.autoDispose
    .family<AudienceBoard, String>((ref, fairId) async {
  return ref.watch(fairAudienceRepositoryProvider).board(fairId);
});

/// Opinión de los compañeros sobre un proyecto propio.
final peerFeedbackProvider = FutureProvider.autoDispose
    .family<PeerFeedback, ({String fairId, String projectId})>(
        (ref, key) async {
  return ref
      .watch(fairAudienceRepositoryProvider)
      .feedback(key.fairId, key.projectId);
});
