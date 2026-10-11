import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/data/repositories/teaching_evaluation_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cliente que responde por ruta y registra lo enviado.
class _ApiClient extends ApiClient {
  _ApiClient(this.routes) : super(storage: SecureStorage());

  final Map<String, Response<dynamic>> routes;
  final calls = <String>[];
  final bodies = <String, Object?>{};
  Map<String, dynamic>? lastQuery;

  Response<dynamic> _route(String method, String path, [Object? body]) {
    calls.add('$method $path');
    bodies['$method $path'] = body;
    return routes['$method $path'] ?? _response(404, null);
  }

  @override
  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic>? query}) async {
    lastQuery = query;
    return _route('GET', path);
  }

  @override
  Future<Response<dynamic>> post(String path,
          {Object? body,
          Map<String, dynamic>? query,
          Map<String, dynamic>? headers}) async =>
      _route('POST', path, body);

  @override
  Future<Response<dynamic>> put(String path, {Object? body}) async =>
      _route('PUT', path, body);

  @override
  Future<Response<dynamic>> patch(String path, {Object? body}) async =>
      _route('PATCH', path, body);
}

Response<dynamic> _response(int statusCode, Object? data) => Response(
      requestOptions: RequestOptions(path: '/api/academic'),
      statusCode: statusCode,
      data: data,
    );

Response<dynamic> _ok(Object? data) =>
    _response(200, {'success': true, 'data': data});

const _base = '/api/academic';

void main() {
  test('pide los criterios activos de la sede y carrera', () async {
    final api = _ApiClient({
      'GET $_base/evaluation-criteria': _ok([
        {'id': 'c-1', 'name': 'Dominio', 'isActive': true},
        {'id': 'c-2', 'name': 'Inactivo', 'isActive': false},
      ]),
    });
    final result = await TeachingEvaluationRepositoryImpl(api)
        .getCriteria(siteId: 'site-1', careerId: 'career-1');

    expect(api.lastQuery, {'siteId': 'site-1', 'careerId': 'career-1'});
    expect(result.dataOrNull!.map((c) => c.id), ['c-1']);
  });

  test('encuentra el borrador de la asignación con sus puntajes', () async {
    final api = _ApiClient({
      'GET $_base/evaluation-responses/mine': _ok([
        {'id': 'r-0', 'teachingAssignmentId': 'otra'},
        {'id': 'r-1', 'teachingAssignmentId': 'a-1', 'status': 'DRAFT'},
      ]),
      'GET $_base/evaluation-responses/r-1': _ok({
        'id': 'r-1',
        'status': 'DRAFT',
        'comment': 'Bien',
        'details': [
          {'criterionId': 'c-1', 'score': 4},
        ],
      }),
    });
    final draft = (await TeachingEvaluationRepositoryImpl(api).findDraft('a-1'))
        .dataOrNull;

    expect(draft!.id, 'r-1');
    expect(draft.scores, {'c-1': 4});
    expect(draft.comment, 'Bien');
    expect(draft.submitted, isFalse);
  });

  test('sin evaluación iniciada devuelve null', () async {
    final api = _ApiClient({'GET $_base/evaluation-responses/mine': _ok([])});
    final result = await TeachingEvaluationRepositoryImpl(api).findDraft('a-1');
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, isNull);
  });

  test('usa el contrato del backend al crear, calificar y enviar', () async {
    final api = _ApiClient({
      'POST $_base/evaluation-responses': _response(201, {
        'success': true,
        'data': {'id': 'r-1', 'status': 'DRAFT'}
      }),
      'PUT $_base/evaluation-responses/r-1/details/c-1': _ok({}),
      'PATCH $_base/evaluation-responses/r-1/comment': _ok({}),
      'POST $_base/evaluation-responses/r-1/submit': _ok({}),
    });
    final repository = TeachingEvaluationRepositoryImpl(api);

    final draft = await repository.createDraft('a-1');
    await repository.saveScore(responseId: 'r-1', criterionId: 'c-1', score: 5);
    await repository.saveComment(responseId: 'r-1', comment: '   ');
    final submitted =
        await repository.submit(responseId: 'r-1', overallRating: 4);

    expect(draft.dataOrNull!.id, 'r-1');
    expect(api.bodies['POST $_base/evaluation-responses'],
        {'teachingAssignmentId': 'a-1'});
    expect(api.bodies['PUT $_base/evaluation-responses/r-1/details/c-1'],
        {'score': 5});
    expect(api.bodies['PATCH $_base/evaluation-responses/r-1/comment'],
        {'comment': null});
    expect(api.bodies['POST $_base/evaluation-responses/r-1/submit'],
        {'overall_rating': 4});
    expect(submitted.isSuccess, isTrue);
  });

  test('un error HTTP no se toma como envío exitoso', () async {
    final api = _ApiClient({
      'POST $_base/evaluation-responses/r-1/submit': _response(403, {
        'success': false,
        'error': {'message': 'Forbidden'},
      }),
    });
    final result = await TeachingEvaluationRepositoryImpl(api)
        .submit(responseId: 'r-1', overallRating: 5);

    expect(result.failureOrNull, isA<ForbiddenFailure>());
  });

  test('el endpoint antiguo ya no se usa', () async {
    final api = _ApiClient({'GET $_base/my-teaching-assignments': _ok([])});
    await TeachingEvaluationRepositoryImpl(api).getMyAssignments();
    expect(api.calls.any((c) => c.contains('teacher-evaluations')), isFalse);
  });
}
