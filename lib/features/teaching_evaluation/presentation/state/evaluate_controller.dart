import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/teaching_assignment.dart';
import 'teaching_evaluation_providers.dart';
import 'teaching_list_controller.dart';

class EvaluateState {
  final bool submitting;
  final bool checkingStatus;
  final bool needsStatusCheck;
  final bool statusConfirmedPending;
  final bool confirmed;
  final String? errorMessage;

  const EvaluateState({
    this.submitting = false,
    this.checkingStatus = false,
    this.needsStatusCheck = false,
    this.statusConfirmedPending = false,
    this.confirmed = false,
    this.errorMessage,
  });

  EvaluateState copyWith({
    bool? submitting,
    bool? checkingStatus,
    bool? needsStatusCheck,
    bool? statusConfirmedPending,
    bool? confirmed,
    String? errorMessage,
    bool clearError = false,
  }) =>
      EvaluateState(
        submitting: submitting ?? this.submitting,
        checkingStatus: checkingStatus ?? this.checkingStatus,
        needsStatusCheck: needsStatusCheck ?? this.needsStatusCheck,
        statusConfirmedPending:
            statusConfirmedPending ?? this.statusConfirmedPending,
        confirmed: confirmed ?? this.confirmed,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

/// Controla el envío y verifica el estado del servidor si se pierde la respuesta.
class EvaluateTeacherController extends StateNotifier<EvaluateState> {
  EvaluateTeacherController(this._ref, this.assignmentId)
      : super(const EvaluateState());

  final Ref _ref;
  final String assignmentId;

  Future<bool> submit({required int score, String? comment}) async {
    if (state.submitting ||
        state.checkingStatus ||
        state.needsStatusCheck ||
        state.confirmed) {
      return false;
    }
    state = state.copyWith(
      submitting: true,
      statusConfirmedPending: false,
      clearError: true,
    );
    late final Result<TeacherEvaluationResult> result;
    try {
      result = await _ref.read(evaluateTeacherUseCaseProvider)(
        assignmentId: assignmentId,
        score: score,
        comment: comment,
      );
    } catch (error) {
      result = FailureResult(mapExceptionToFailure(error));
    }

    if (result case Success<TeacherEvaluationResult>()) {
      state = state.copyWith(
        submitting: false,
        checkingStatus: true,
        needsStatusCheck: true,
        errorMessage:
            'El servidor recibió la evaluación. Estamos verificando el estado de la asignación.',
      );
      // La respuesta del POST confirma que se procesó la solicitud, pero la
      // lista de asignaciones es la fuente del estado `evaluated` que muestra
      // la pantalla de éxito. No marcarlo localmente antes de comprobarlo.
      return _reconcile();
    }

    final failure = (result as FailureResult<TeacherEvaluationResult>).failure;
    if (_needsReconciliation(failure)) {
      state = state.copyWith(
        submitting: false,
        checkingStatus: true,
        needsStatusCheck: true,
        errorMessage:
            'No recibimos confirmación. Estamos comprobando el estado antes de permitir otro envío.',
      );
      return _reconcile();
    }

    state = state.copyWith(
      submitting: false,
      errorMessage: _submissionFailureMessage(failure),
    );
    return false;
  }

  /// Consulta el campo `evaluated` de las asignaciones reales del estudiante.
  Future<bool> checkStatus() async {
    if (state.checkingStatus || !state.needsStatusCheck || state.confirmed) {
      return state.confirmed;
    }
    state = state.copyWith(checkingStatus: true, clearError: true);
    return _reconcile();
  }

  Future<bool> _reconcile() async {
    try {
      final result = await _ref.read(getMyTeachingAssignmentsUseCaseProvider)();
      final assignments = result.dataOrNull;
      if (assignments != null) {
        _ref
            .read(teachingListControllerProvider.notifier)
            .replaceFromServer(assignments);
      }
      TeachingAssignment? assignment;
      for (final item in assignments ?? const <TeachingAssignment>[]) {
        if (item.id == assignmentId) {
          assignment = item;
          break;
        }
      }
      if (assignment?.evaluated == true) {
        _markEvaluated();
        state = state.copyWith(
          checkingStatus: false,
          needsStatusCheck: false,
          confirmed: true,
          clearError: true,
        );
        return true;
      }

      if (assignment != null && assignment.isActive && !assignment.evaluated) {
        state = state.copyWith(
          checkingStatus: false,
          needsStatusCheck: false,
          statusConfirmedPending: true,
          errorMessage:
              'El servidor confirma que sigue pendiente. Revisa la selección y confirma antes de volver a enviarla.',
        );
        return false;
      }

      state = state.copyWith(
        checkingStatus: false,
        needsStatusCheck: true,
        errorMessage: result.isFailure
            ? 'No pudimos comprobar si se registró. Consulta el estado antes de volver a intentarlo.'
            : 'El servidor aún no confirma la evaluación. Consulta el estado antes de volver a intentarlo.',
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        checkingStatus: false,
        needsStatusCheck: true,
        errorMessage:
            'No pudimos comprobar si se registró. Consulta el estado antes de volver a intentarlo.',
      );
      return false;
    }
  }

  void _markEvaluated() => _ref
      .read(teachingListControllerProvider.notifier)
      .markEvaluated(assignmentId);

  bool _needsReconciliation(Failure failure) =>
      failure is TimeoutFailure ||
      failure is NetworkFailure ||
      failure is ServerFailure ||
      failure is ConflictFailure ||
      failure is UnknownFailure;

  String _submissionFailureMessage(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return 'Tu sesión venció. Inicia sesión de nuevo.';
    }
    if (failure is ForbiddenFailure) {
      return 'No tienes permiso para enviar esta evaluación.';
    }
    if (failure is ValidationFailure) {
      return 'Revisa la calificación y el comentario antes de continuar.';
    }
    if (failure is NotFoundFailure || failure is ConflictFailure) {
      return 'Esta asignación ya no está disponible. Actualiza la lista de docentes.';
    }
    return 'No pudimos enviar la evaluación. Revisa el estado antes de intentarlo de nuevo.';
  }
}

final evaluateTeacherControllerProvider = StateNotifierProvider.family<
    EvaluateTeacherController, EvaluateState, String>(
  (ref, assignmentId) => EvaluateTeacherController(ref, assignmentId),
);
