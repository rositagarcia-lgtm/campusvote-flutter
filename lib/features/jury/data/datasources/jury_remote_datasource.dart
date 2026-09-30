import 'package:dio/dio.dart';

import '../../../../core/config/endpoints.dart';
import '../../../../core/network/api_client.dart';

/// Error de dominio del panel de jurado.
///
/// Envuelve el `code`/`status` del backend para que la UI pueda decidir sin
/// conocer Dio: 403 = sin permisos, 409 = conflicto (rúbrica ya finalizada,
/// voto repetido, declaración duplicada), 400 = payload inválido.
class JuryApiException implements Exception {
  const JuryApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  bool get isForbidden => statusCode == 403;
  bool get isConflict => statusCode == 409;
  bool get isBadRequest => statusCode == 400;
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'JuryApiException($statusCode/$code): $message';
}

/// DataSource del jurado: un método por endpoint.
///
/// Usa [ApiClient] (no un `Dio` pelado) porque es el que inyecta el Bearer y
/// refresca el token en 401; con Dio sin interceptores toda llamada sería 401.
class JuryRemoteDataSource {
  JuryRemoteDataSource(this._client);

  final ApiClient _client;

  // ── Dashboard ─────────────────────────────────────────────────────────

  /// `GET /fairs/my-assignments`
  Future<Map<String, dynamic>> getMyAssignments({
    int page = 1,
    int limit = 50,
  }) =>
      _get(
        JuryEndpoints.myAssignments,
        query: {'page': page, 'limit': limit},
      );

  /// `GET /fairs/my-progress/:fairId`
  Future<Map<String, dynamic>> getMyProgress(String fairId) =>
      _get(JuryEndpoints.myProgress(fairId));

  // ── Proyectos ─────────────────────────────────────────────────────────

  /// `GET /fairs/:fairId/projects` — ya viene filtrado por categoría.
  Future<Map<String, dynamic>> getFairProjects(
    String fairId, {
    int page = 1,
    int limit = 100,
    String? search,
  }) =>
      _get(
        JuryEndpoints.projects(fairId),
        query: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

  // ── Rúbrica ───────────────────────────────────────────────────────────

  /// `GET /fairs/:fairId/projects/:projectId/rubric`
  Future<Map<String, dynamic>> getProjectRubric(
    String fairId,
    String projectId,
  ) =>
      _get(JuryEndpoints.projectRubric(fairId, projectId));

  /// `PUT /fairs/:fairId/projects/:projectId/rubric`
  ///
  /// El body es `.strict()`: solo `responses[{criterion_id, checked}]` y
  /// `finalize`. Mandar un score calculado o un comentario produce 400.
  Future<Map<String, dynamic>> saveProjectRubric(
    String fairId,
    String projectId, {
    required List<Map<String, dynamic>> responses,
    required bool finalize,
  }) =>
      _put(
        JuryEndpoints.projectRubric(fairId, projectId),
        body: {'responses': responses, 'finalize': finalize},
      );

  // ── Votación ──────────────────────────────────────────────────────────

  /// `GET /fairs/:fairId/voting/status`
  Future<Map<String, dynamic>> getVotingStatus(String fairId) =>
      _get(JuryEndpoints.votingStatus(fairId));

  /// `POST /fairs/:fairId/votes` — body `.strict()`: solo `project_id`.
  Future<Map<String, dynamic>> castVote(
    String fairId,
    String projectId,
  ) =>
      _post(JuryEndpoints.castVote(fairId), body: {'project_id': projectId});

  // ── Declaración ───────────────────────────────────────────────────────

  /// `GET /fairs/:fairId/jury/declaration`
  Future<Map<String, dynamic>> getDeclaration(String fairId) =>
      _get(JuryEndpoints.declaration(fairId));

  /// `POST /fairs/:fairId/jury/declaration` — body `.strict()`: `statement`.
  Future<Map<String, dynamic>> signDeclaration(
    String fairId,
    String statement,
  ) =>
      _post(
        JuryEndpoints.declaration(fairId),
        body: {'statement': statement},
      );

  // ── Resultados ────────────────────────────────────────────────────────

  /// `GET /fairs/:fairId/results` — **ADMIN-only**: un JURY recibe 403.
  Future<Map<String, dynamic>> getResults(String fairId) =>
      _get(JuryEndpoints.results(fairId));

  /// `GET /fairs/my-evaluations`
  Future<Map<String, dynamic>> getMyEvaluations({
    int page = 1,
    int limit = 50,
    String? fairId,
  }) =>
      _get(
        JuryEndpoints.myEvaluations,
        query: {
          'page': page,
          'limit': limit,
          if (fairId != null && fairId.isNotEmpty) 'fair_id': fairId,
        },
      );

  // ── Transporte ────────────────────────────────────────────────────────

  /// Desenvuelve `{ success, data, meta }` y traduce los errores.
  Future<Map<String, dynamic>> _unwrap(Response<dynamic> response) async {
    final body = response.data;
    if (body is! Map) {
      throw JuryApiException(
        'Respuesta inesperada del servidor',
        statusCode: response.statusCode,
      );
    }
    final map = Map<String, dynamic>.from(body);
    if (map['success'] == true) return map;

    final error = map['error'];
    final err =
        error is Map ? Map<String, dynamic>.from(error) : <String, dynamic>{};
    throw JuryApiException(
      (err['message'] ?? map['message'] ?? 'Error del servidor').toString(),
      statusCode: response.statusCode,
      code: err['code']?.toString(),
    );
  }

  Never _rethrow(Object error) {
    if (error is JuryApiException) throw error;
    if (error is DioException) {
      final status = error.response?.statusCode;
      final body = error.response?.data;
      String? code;
      String? message;
      if (body is Map) {
        final err = body['error'];
        if (err is Map) {
          code = err['code']?.toString();
          message = err['message']?.toString();
        }
        message ??= body['message']?.toString();
      }
      throw JuryApiException(
        message ?? _fallbackMessage(status, error.type),
        statusCode: status,
        code: code,
      );
    }
    throw JuryApiException(error.toString());
  }

  String _fallbackMessage(int? status, DioExceptionType type) {
    if (status != null && status >= 500) {
      return 'El servidor falló, inténtalo más tarde';
    }
    return switch (status) {
      400 => 'La solicitud es inválida',
      401 => 'Tu sesión expiró',
      403 => 'No tienes permisos para esta operación',
      404 => 'El recurso no existe',
      409 => 'La operación entra en conflicto con el estado actual',
      _ => type == DioExceptionType.connectionError ||
              type == DioExceptionType.connectionTimeout
          ? 'Sin conexión con el servidor'
          : 'Error de red',
    };
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _unwrap(await _client.get(path, query: query));
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    Object? body,
  }) async {
    try {
      return await _unwrap(await _client.post(path, body: body));
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<Map<String, dynamic>> _put(
    String path, {
    Object? body,
  }) async {
    try {
      return await _unwrap(await _client.put(path, body: body));
    } catch (e) {
      _rethrow(e);
    }
  }
}
