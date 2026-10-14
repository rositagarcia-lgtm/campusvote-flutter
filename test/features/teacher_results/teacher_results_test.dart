import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/teacher_results/data/teacher_results_repository.dart';
import 'package:campusvote_flutter/features/teacher_results/domain/teacher_results.dart';
import 'package:campusvote_flutter/features/teacher_results/presentation/teacher_results_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ApiClient extends ApiClient {
  _ApiClient(this.routes) : super(storage: SecureStorage());

  final Map<String, Response<dynamic>> routes;

  @override
  Future<Response<dynamic>> get(String path,
          {Map<String, dynamic>? query}) async =>
      routes[path.split('/').last] ?? _response(404, null);
}

Response<dynamic> _response(int status, Object? data) => Response(
      requestOptions: RequestOptions(path: '/api/academic'),
      statusCode: status,
      data: data,
    );

Response<dynamic> _ok(Object? data, {int total = 5}) => _response(200, {
      'success': true,
      'data': data,
      'meta': {'total_responses': total, 'minimum_required': 3},
    });

const _available = TeacherResults(
  status: TeacherResultsStatus.available,
  totalResponses: 12,
  overallAverage: 4.25,
  overallRating: 4.0,
  byCriterion: [
    CriterionResult(name: 'Claridad', average: 4.6),
    CriterionResult(name: 'Puntualidad', average: 3.4),
  ],
  byCourse: [
    CourseResult(
        courseName: 'Matemática',
        courseCode: 'MAT1',
        average: 4.2,
        responses: 8),
  ],
  distribution: {5: 10, 4: 6, 3: 3, 2: 1, 1: 0},
  comments: ['Explica muy bien'],
);

Widget _page(TeacherResults results) => ProviderScope(
      overrides: [
        teacherResultsProvider.overrideWith((ref) async => results),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const TeacherResultsPage(),
      ),
    );

void main() {
  group('TeacherResultsRepository', () {
    test('jornada abierta (409): resultados bloqueados', () async {
      final api = _ApiClient({
        'summary': _response(409, {'success': false}),
      });
      final results = await TeacherResultsRepository(api).load('t-1');
      expect(results.status, TeacherResultsStatus.locked);
    });

    test('menos respuestas que el mínimo: no muestra datos', () async {
      final api = _ApiClient({'summary': _ok(null, total: 2)});
      final results = await TeacherResultsRepository(api).load('t-1');
      expect(results.status, TeacherResultsStatus.insufficient);
      expect(results.totalResponses, 2);
      expect(results.minimumRequired, 3);
    });

    test('lee resumen, criterios, distribución, comentarios y evolución',
        () async {
      final api = _ApiClient({
        'summary': _ok({
          'overallAverage': 4.17,
          'overallRatingAverage': 4,
          'totalResponses': 5,
          'byCourse': [
            {
              'averageScore': 4.17,
              'totalResponses': 5,
              'cycle': 2,
              'course': {'code': 'MAT1', 'name': 'Matemática'},
              'academicPeriod': {'name': '2026-II'},
            },
          ],
        }),
        'criteria': _ok({
          'byCriterion': [
            {'name': 'Claridad', 'averageScore': 4.5},
            {'name': 'Puntualidad', 'averageScore': 3.8},
          ],
        }),
        'distribution': _ok({
          'distribution': [
            {'score': 5, 'count': 4},
            {'score': 4, 'count': 1},
          ],
        }),
        'comments': _ok({
          'comments': ['Muy claro', '   '],
        }),
        'evolution': _ok({
          'evolution': [
            {
              'academicPeriod': {'name': '2026-II'},
              'averageScore': 4.17,
              'totalResponses': 5,
            },
          ],
        }),
      });
      final results = await TeacherResultsRepository(api).load('t-1');

      expect(results.status, TeacherResultsStatus.available);
      expect(results.overallAverage, 4.17);
      expect(results.overallRating, 4);
      expect(results.byCourse.single.periodName, '2026-II');
      expect(results.strongest!.name, 'Claridad');
      expect(results.weakest!.name, 'Puntualidad');
      expect(results.distribution, {5: 4, 4: 1});
      expect(results.comments, ['Muy claro']);
      expect(results.evolution.single.average, 4.17);
    });
  });

  group('TeacherResultsPage', () {
    testWidgets('muestra promedio, fortaleza, mejora y comentarios',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 1600));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_page(_available));
      await tester.pumpAndSettle();

      expect(find.text('4.3'), findsOneWidget);
      expect(find.text('12 evaluaciones'), findsOneWidget);
      expect(find.text('Tu fortaleza'), findsOneWidget);
      expect(find.text('Para mejorar'), findsOneWidget);
      expect(find.text('Explica muy bien'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('jornada abierta: explica por qué aún no hay resultados',
        (tester) async {
      await tester.pumpWidget(
          _page(const TeacherResults(status: TeacherResultsStatus.locked)));
      await tester.pumpAndSettle();
      expect(
          find.text('La jornada de evaluación sigue abierta'), findsOneWidget);
    });

    testWidgets('pocas respuestas: protege el anonimato', (tester) async {
      await tester.pumpWidget(_page(const TeacherResults(
        status: TeacherResultsStatus.insufficient,
        totalResponses: 2,
      )));
      await tester.pumpAndSettle();
      expect(find.text('Aún no hay suficientes evaluaciones'), findsOneWidget);
      expect(find.textContaining('llevas 2 de 3'), findsOneWidget);
    });
  });
}
