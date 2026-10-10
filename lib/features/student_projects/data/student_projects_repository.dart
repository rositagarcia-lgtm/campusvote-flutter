import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../auth/domain/entities/auth_role.dart';
import '../../auth/presentation/state/auth_controller.dart';
import '../domain/student_project.dart';

class StudentProjectsRepository {
  StudentProjectsRepository(this._client);

  final ApiClient _client;

  /// Proyectos del alumno. Un 404 significa que el backend aún no publica el
  /// endpoint: se trata como "sin proyectos" para no mostrar un error a quien
  /// simplemente no participa en ninguna feria.
  Future<Result<List<StudentProject>>> myProjects() async {
    try {
      final res = await _client.get(ApiEndpoints.myStudentProjects);
      if (res.statusCode == 404) return const Success([]);
      final data = _data(res, ApiEndpoints.myStudentProjects);
      if (data is! List) {
        throw const FormatException('Lista de proyectos no válida.');
      }
      return Success(data
          .whereType<Map>()
          .map((m) => StudentProject.fromJson(Map<String, dynamic>.from(m)))
          .toList(growable: false));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const Success([]);
      return FailureResult(mapExceptionToFailure(e));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<ProjectFeedback>> feedback(StudentProject project) async {
    final fairId = project.fair?.id;
    if (fairId == null) {
      return const Success(ProjectFeedback(likes: 0, comments: []));
    }
    final path = ApiEndpoints.projectEngagement(fairId, project.id);
    try {
      final data = _data(await _client.get(path), path);
      if (data is! Map) {
        throw const FormatException('Respuesta de valoraciones no válida.');
      }
      return Success(ProjectFeedback.fromJson(Map<String, dynamic>.from(data)));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Object? _data(Response<dynamic> res, String path) {
    if ((res.statusCode ?? 500) >= 400) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: res,
        type: DioExceptionType.badResponse,
      );
    }
    final body = res.data;
    return body is Map ? body['data'] : body;
  }
}

final studentProjectsRepositoryProvider = Provider<StudentProjectsRepository>(
  (ref) => StudentProjectsRepository(ref.watch(apiClientProvider)),
);

/// Proyectos de feria del alumno; se vuelve a pedir con `ref.invalidate`.
final studentProjectsProvider =
    FutureProvider.autoDispose<List<StudentProject>>((ref) async {
  // Solo un alumno con sesión tiene proyectos propios: sin esto la barra
  // inferior pedía /projects/mine tras cerrar sesión y recibía 401.
  final isStudent = ref.watch(authControllerProvider
      .select((s) => s.authenticated && s.user?.role == AuthRole.student));
  if (!isStudent) return const [];
  final result =
      await ref.watch(studentProjectsRepositoryProvider).myProjects();
  return result.when(success: (d) => d, failure: (f) => throw f);
});

/// La pestaña "Mis proyectos" solo existe para alumnos con algún proyecto.
/// Mientras carga o si falla, la pestaña no aparece.
final hasStudentProjectsProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(studentProjectsProvider).valueOrNull?.isNotEmpty ?? false,
);

final projectFeedbackProvider = FutureProvider.autoDispose
    .family<ProjectFeedback, StudentProject>((ref, project) async {
  final result =
      await ref.watch(studentProjectsRepositoryProvider).feedback(project);
  return result.when(success: (d) => d, failure: (f) => throw f);
});
