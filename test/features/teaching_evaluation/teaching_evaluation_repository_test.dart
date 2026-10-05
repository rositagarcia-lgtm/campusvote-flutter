import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:campusvote_flutter/features/teaching_evaluation/data/repositories/teaching_evaluation_repository_impl.dart';
import 'package:campusvote_flutter/core/errors/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _ApiClient extends ApiClient {
  _ApiClient({this.postResponse}) : super(storage: SecureStorage());

  Response<dynamic>? postResponse;
  Object? lastBody;

  @override
  Future<Response<dynamic>> get(String path,
          {Map<String, dynamic>? query}) async =>
      _response(404, null);

  @override
  Future<Response<dynamic>> post(String path,
      {Object? body,
      Map<String, dynamic>? query,
      Map<String, dynamic>? headers}) async {
    lastBody = body;
    return postResponse!;
  }
}

Response<dynamic> _response(int statusCode, Object? data) => Response(
      requestOptions: RequestOptions(path: '/academic/teacher-evaluations'),
      statusCode: statusCode,
      data: data,
    );

void main() {
  test('HTTP error from evaluation is not treated as a successful submission',
      () async {
    final api = _ApiClient(
      postResponse: _response(403, {
        'success': false,
        'error': {'message': 'Forbidden'},
      }),
    );
    final repository = TeachingEvaluationRepositoryImpl(api);

    final result = await repository.evaluateTeacher(
      assignmentId: 'assignment-1',
      score: 5,
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ForbiddenFailure>());
  });

  test('POST usa el contrato existente y solo confirma con respuesta 2xx',
      () async {
    final api = _ApiClient(
      postResponse: _response(201, {
        'success': true,
        'data': {
          'id': 'evaluation-1',
          'score': 4,
          'created_at': '2026-10-01T10:00:00.000Z',
        },
      }),
    );
    final repository = TeachingEvaluationRepositoryImpl(api);

    final result = await repository.evaluateTeacher(
      assignmentId: 'assignment-1',
      score: 4,
      comment: '  Mejorar ejemplos  ',
    );

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.id, 'evaluation-1');
    expect(api.lastBody, {
      'teaching_assignment_id': 'assignment-1',
      'score': 4,
      'comment': '  Mejorar ejemplos  ',
    });
  });

  test('respuesta exitosa sin payload no confirma la evaluación', () async {
    final api = _ApiClient(postResponse: _response(200, {'success': true}));
    final repository = TeachingEvaluationRepositoryImpl(api);

    final result = await repository.evaluateTeacher(
      assignmentId: 'assignment-1',
      score: 2,
    );

    expect(result.isFailure, isTrue);
  });
}
