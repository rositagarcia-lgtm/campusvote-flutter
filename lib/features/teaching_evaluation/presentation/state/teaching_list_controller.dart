import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/teaching_assignment.dart';
import 'teaching_evaluation_providers.dart';

class TeachingListState {
  final bool loading;
  final List<TeachingAssignment> items;
  final String? errorMessage;

  const TeachingListState({
    this.loading = false,
    this.items = const [],
    this.errorMessage,
  });

  TeachingListState copyWith({
    bool? loading,
    List<TeachingAssignment>? items,
    String? errorMessage,
    bool clearError = false,
  }) =>
      TeachingListState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  List<TeachingAssignment> get pending =>
      items.where((a) => !a.evaluated).toList(growable: false);
  List<TeachingAssignment> get done =>
      items.where((a) => a.evaluated).toList(growable: false);
  bool get isEmpty => items.isEmpty && !loading;
}

class TeachingListController extends StateNotifier<TeachingListState> {
  TeachingListController(this._ref)
      : super(const TeachingListState(loading: true)) {
    load();
  }

  final Ref _ref;
  bool _requestInFlight = false;

  Future<void> load() async {
    if (_requestInFlight) return;
    _requestInFlight = true;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final res = await _ref.read(getMyTeachingAssignmentsUseCaseProvider)();
      res.when(
        success: (items) {
          state = state.copyWith(loading: false, items: items);
        },
        failure: (f) {
          state = state.copyWith(
            loading: false,
            errorMessage: teachingFailureMessage(f),
          );
        },
      );
    } catch (_) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'No pudimos cargar tus asignaciones. Inténtalo de nuevo.',
      );
    } finally {
      _requestInFlight = false;
    }
  }

  Future<void> refresh() async => load();

  /// Reemplaza la lista únicamente con una respuesta autoritativa del servidor.
  void replaceFromServer(List<TeachingAssignment> assignments) {
    state = state.copyWith(
      items: assignments,
      loading: false,
      clearError: true,
    );
  }

  /// Marca una asignación como evaluada tras un submit exitoso.
  void markEvaluated(String assignmentId) {
    state = state.copyWith(
      items: [
        for (final a in state.items)
          if (a.id == assignmentId)
            TeachingAssignment(
              id: a.id,
              courseId: a.courseId,
              teacherId: a.teacherId,
              courseCode: a.courseCode,
              courseName: a.courseName,
              cycle: a.cycle,
              teacherFirstName: a.teacherFirstName,
              teacherLastName: a.teacherLastName,
              evaluated: true,
              isActive: a.isActive,
            )
          else
            a,
      ],
    );
  }
}

String teachingFailureMessage(Failure failure) {
  final statusCode = failure.statusCode;
  if (statusCode == 401) return 'Tu sesión venció. Inicia sesión de nuevo.';
  if (statusCode == 403) {
    return 'No tienes permiso para consultar estas asignaciones.';
  }
  if (statusCode == 404) {
    return 'No encontramos las asignaciones docentes de este periodo.';
  }
  if (failure.code == 'TIMEOUT') {
    return 'La solicitud tardó demasiado. Comprueba tu conexión e inténtalo de nuevo.';
  }
  if (failure.code == 'NETWORK') {
    return 'No se pudo contactar al servidor. Comprueba tu conexión e inténtalo de nuevo.';
  }
  if (statusCode != null && statusCode >= 500) {
    return 'El servicio no está disponible por el momento. Inténtalo de nuevo más tarde.';
  }
  return 'No pudimos cargar tus asignaciones. Inténtalo de nuevo.';
}

final teachingListControllerProvider =
    StateNotifierProvider<TeachingListController, TeachingListState>(
  (ref) => TeachingListController(ref),
);
