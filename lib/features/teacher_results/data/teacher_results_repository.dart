import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/state/auth_controller.dart';
import '../domain/evaluation_progress.dart';
import '../domain/teacher_results.dart';

/// Resultados de la evaluación docente del docente autenticado
/// (`/api/academic/evaluation-results/teacher/:id/*`).
///
/// El backend devuelve 409 mientras la jornada está abierta y `data: null`
/// si hay menos respuestas que el mínimo.
class TeacherResultsRepository {
  TeacherResultsRepository(this._client);
  final ApiClient _client;

  static String _path(String teacherId, String part) =>
      '/api/academic/evaluation-results/teacher/$teacherId/$part';

  Future<TeacherResults> load(String teacherId) async {
    final summary = await _get(_path(teacherId, 'summary'));
    if (summary == null) {
      return const TeacherResults(status: TeacherResultsStatus.locked);
    }
    final meta = _map(summary['meta']);
    final minimum = _int(meta['minimum_required'], 3);
    final data = summary['data'];
    if (data is! Map) {
      return TeacherResults(
        status: TeacherResultsStatus.insufficient,
        totalResponses: _int(meta['total_responses'], 0),
        minimumRequired: minimum,
      );
    }

    final parts = await Future.wait([
      _get(_path(teacherId, 'criteria')),
      _get(_path(teacherId, 'distribution')),
      _get(_path(teacherId, 'comments')),
      _get(_path(teacherId, 'evolution')),
    ]);
    final criteria = _map(parts[0]?['data']);
    final distribution = _map(parts[1]?['data']);
    final comments = _map(parts[2]?['data']);
    final evolution = _map(parts[3]?['data']);
    final main = Map<String, dynamic>.from(data);

    return TeacherResults(
      status: TeacherResultsStatus.available,
      totalResponses: _int(main['totalResponses'], 0),
      minimumRequired: minimum,
      overallAverage: _double(main['overallAverage']) ?? 0,
      overallRating: _double(main['overallRatingAverage']),
      byCourse: [
        for (final c in _list(main['byCourse']))
          CourseResult(
            courseName: _text(_map(c['course'])['name']),
            courseCode: _text(_map(c['course'])['code']),
            cycle: c['cycle'] is num ? (c['cycle'] as num).toInt() : null,
            periodName: _nullable(_map(c['academicPeriod'])['name']),
            average: _double(c['averageScore']) ?? 0,
            responses: _int(c['totalResponses'], 0),
          ),
      ],
      byCriterion: [
        // Incluye criterios ya desactivados: se evaluaron con ellos.
        for (final c in _list(criteria['byCriterion']))
          CriterionResult(
            name: _text(c['name']),
            description: _nullable(c['description']),
            average: _double(c['averageScore']) ?? 0,
          ),
      ],
      distribution: {
        for (final d in _list(distribution['distribution']))
          _int(d['score'], 0): _int(d['count'], 0),
      },
      comments: [
        for (final c in comments['comments'] is List
            ? comments['comments'] as List
            : const [])
          if (c.toString().trim().isNotEmpty) c.toString().trim(),
      ],
      evolution: [
        for (final p in _list(evolution['evolution']))
          PeriodResult(
            periodName: _text(_map(p['academicPeriod'])['name']),
            average: _double(p['averageScore']) ?? 0,
            responses: _int(p['totalResponses'], 0),
          ),
      ],
    );
  }

  /// Cuerpo de la respuesta, o `null` si la jornada sigue abierta (409).
  Future<Map<String, dynamic>?> _get(String path) async {
    try {
      final response = await _client.get(path);
      final status = response.statusCode ?? 500;
      if (status == 409) return null;
      if (status >= 400) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
      return _map(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return null;
      rethrow;
    }
  }

  /// Jornadas publicadas de mis cursos con cuántos alumnos ya me evaluaron.
  Future<List<ScheduleProgress>> progress() async {
    final body = await _get('/api/academic/evaluation-progress/me');
    final data = _map(body?['data']);
    return [
      for (final s in _list(data['schedules'])) ScheduleProgress.fromJson(s),
    ];
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static List<Map<String, dynamic>> _list(Object? value) => value is List
      ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
      : const [];

  static String _text(Object? value) => (value ?? '').toString();

  static String? _nullable(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static int _int(Object? value, int fallback) =>
      value is num ? value.toInt() : fallback;

  static double? _double(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('${value ?? ''}');
}

final teacherResultsRepositoryProvider = Provider<TeacherResultsRepository>(
  (ref) => TeacherResultsRepository(ref.watch(apiClientProvider)),
);

/// Resultados del docente en sesión.
final teacherResultsProvider =
    FutureProvider.autoDispose<TeacherResults>((ref) async {
  final userId =
      ref.watch(authControllerProvider.select((s) => s.user?.id)) ?? '';
  if (userId.isEmpty) {
    return const TeacherResults(status: TeacherResultsStatus.insufficient);
  }
  return ref.read(teacherResultsRepositoryProvider).load(userId);
});

/// Avance de la evaluación del docente autenticado (solo conteos).
final teacherEvaluationProgressProvider =
    FutureProvider.autoDispose<List<ScheduleProgress>>((ref) {
  return ref.watch(teacherResultsRepositoryProvider).progress();
});
