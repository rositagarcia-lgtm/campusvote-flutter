import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/teacher_evaluation_form.dart';
import '../../domain/entities/teaching_assignment.dart';
import 'teaching_evaluation_providers.dart';
import 'teaching_list_controller.dart';

class EvaluateState {
  final bool loading;
  final bool loaded;
  final String? loadError;
  final List<EvaluationCriterion> criteria;
  final Map<String, int> scores;

  /// Criterios cuyo puntaje se está guardando.
  final Set<String> saving;
  final String? draftId;
  final String initialComment;
  final int overall;
  final bool submitting;
  final bool checkingStatus;
  final bool needsStatusCheck;
  final bool statusConfirmedPending;
  final bool confirmed;
  final String? errorMessage;

  const EvaluateState({
    this.loading = false,
    this.loaded = false,
    this.loadError,
    this.criteria = const [],
    this.scores = const {},
    this.saving = const {},
    this.draftId,
    this.initialComment = '',
    this.overall = 0,
    this.submitting = false,
    this.checkingStatus = false,
    this.needsStatusCheck = false,
    this.statusConfirmedPending = false,
    this.confirmed = false,
    this.errorMessage,
  });

  int get answered => criteria.where((c) => scores.containsKey(c.id)).length;
  bool get complete => criteria.isNotEmpty && answered == criteria.length;

  /// No se puede editar mientras se envía, se verifica o ya se envió.
  bool get locked =>
      submitting || checkingStatus || needsStatusCheck || confirmed;

  EvaluateState copyWith({
    bool? loading,
    bool? loaded,
    String? loadError,
    List<EvaluationCriterion>? criteria,
    Map<String, int>? scores,
    Set<String>? saving,
    String? draftId,
    String? initialComment,
    int? overall,
    bool? submitting,
    bool? checkingStatus,
    bool? needsStatusCheck,
    bool? statusConfirmedPending,
    bool? confirmed,
    String? errorMessage,
    bool clearError = false,
    bool clearLoadError = false,
  }) =>
      EvaluateState(
        loading: loading ?? this.loading,
        loaded: loaded ?? this.loaded,
        loadError: clearLoadError ? null : (loadError ?? this.loadError),
        criteria: criteria ?? this.criteria,
        scores: scores ?? this.scores,
        saving: saving ?? this.saving,
        draftId: draftId ?? this.draftId,
        initialComment: initialComment ?? this.initialComment,
        overall: overall ?? this.overall,
        submitting: submitting ?? this.submitting,
        checkingStatus: checkingStatus ?? this.checkingStatus,
        needsStatusCheck: needsStatusCheck ?? this.needsStatusCheck,
        statusConfirmedPending:
            statusConfirmedPending ?? this.statusConfirmedPending,
        confirmed: confirmed ?? this.confirmed,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

/// Evaluación por criterios de una asignación: carga la rúbrica y el
/// borrador, guarda cada puntaje al instante y envía al final. Si se pierde
/// la respuesta del envío, consulta el estado real antes de permitir otro.
class EvaluateTeacherController extends StateNotifier<EvaluateState> {
  EvaluateTeacherController(this._ref, this.assignmentId)
      : super(const EvaluateState());

  final Ref _ref;
  final String assignmentId;
  Future<String?>? _draftRequest;

  /// Carga rúbrica y borrador una sola vez (o de nuevo tras un error).
  Future<void> load(TeachingAssignment assignment) async {
    if (state.loading || state.loaded) return;
    state = state.copyWith(loading: true, clearLoadError: true);
    final repo = _ref.read(teachingEvaluationRepositoryProvider);
    try {
      final results = await Future.wait([
        repo.getCriteria(
            siteId: assignment.siteId, careerId: assignment.careerId),
        repo.findDraft(assignmentId),
      ]);
      if (!mounted) return;
      final criteria = results[0] as Result<List<EvaluationCriterion>>;
      final draft = results[1] as Result<EvaluationDraft?>;
      final failure = criteria.failureOrNull ?? draft.failureOrNull;
      if (failure != null) {
        state = state.copyWith(
          loading: false,
          loadError: teachingFailureMessage(failure),
        );
        return;
      }
      final saved = draft.dataOrNull;
      state = state.copyWith(
        loading: false,
        loaded: true,
        // Primero los generales de la sede, luego los de la carrera.
        criteria: [
          ...?criteria.dataOrNull?.where((c) => c.isGeneral),
          ...?criteria.dataOrNull?.where((c) => !c.isGeneral),
        ],
        scores: saved?.scores ?? const {},
        draftId: saved?.id,
        initialComment: saved?.comment ?? '',
      );
      if (saved?.submitted == true) {
        state = state.copyWith(checkingStatus: true, needsStatusCheck: true);
        await _reconcile();
      }
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        loadError: teachingFailureMessage(mapExceptionToFailure(error)),
      );
    }
  }

  /// Califica un criterio y lo guarda en el borrador.
  Future<void> setScore(String criterionId, int score) async {
    if (state.locked || score < 1 || score > 5) return;
    final previous = state.scores[criterionId];
    state = state.copyWith(
      scores: {...state.scores, criterionId: score},
      saving: {...state.saving, criterionId},
      clearError: true,
    );
    final draftId = await _ensureDraft();
    Result<void>? result;
    if (draftId != null) {
      result = await _ref.read(teachingEvaluationRepositoryProvider).saveScore(
            responseId: draftId,
            criterionId: criterionId,
            score: score,
          );
    }
    if (!mounted) return;
    final saving = {...state.saving}..remove(criterionId);
    if (result != null && result.isSuccess) {
      state = state.copyWith(saving: saving);
      return;
    }
    // Se revierte: la pantalla nunca muestra un puntaje que no se guardó.
    final scores = {...state.scores};
    if (previous == null) {
      scores.remove(criterionId);
    } else {
      scores[criterionId] = previous;
    }
    state = state.copyWith(
      saving: saving,
      scores: scores,
      errorMessage: result?.failureOrNull != null
          ? _saveFailureMessage(result!.failureOrNull!)
          : state.errorMessage ??
              'No pudimos guardar tu respuesta. Inténtalo de nuevo.',
    );
  }

  void setOverall(int value) {
    if (state.locked || value < 1 || value > 5) return;
    state = state.copyWith(overall: value, clearError: true);
  }

  Future<bool> submit({String comment = ''}) async {
    if (state.locked || state.saving.isNotEmpty) return false;
    if (!state.complete) {
      state = state.copyWith(
          errorMessage: 'Califica todos los criterios antes de enviar.');
      return false;
    }
    if (state.overall < 1) {
      state = state.copyWith(
          errorMessage: 'Elige la calificación general de 1 a 5.');
      return false;
    }
    state = state.copyWith(
      submitting: true,
      statusConfirmedPending: false,
      clearError: true,
    );
    final draftId = await _ensureDraft();
    if (draftId == null) {
      state = state.copyWith(submitting: false);
      return false;
    }
    final repo = _ref.read(teachingEvaluationRepositoryProvider);
    final commentResult =
        await repo.saveComment(responseId: draftId, comment: comment);
    if (commentResult.failureOrNull case final failure?) {
      state = state.copyWith(
        submitting: false,
        errorMessage: _submissionFailureMessage(failure),
      );
      return false;
    }

    Result<void> result;
    try {
      result = await _ref.read(submitTeacherEvaluationUseCaseProvider)(
        responseId: draftId,
        overallRating: state.overall,
      );
    } catch (error) {
      result = FailureResult(mapExceptionToFailure(error));
    }

    final failure = result.failureOrNull;
    if (failure == null || _needsReconciliation(failure)) {
      state = state.copyWith(
        submitting: false,
        checkingStatus: true,
        needsStatusCheck: true,
        errorMessage: failure == null
            ? 'El servidor recibió la evaluación. Estamos verificando el estado de la asignación.'
            : 'No recibimos confirmación. Estamos comprobando el estado antes de permitir otro envío.',
      );
      // La lista de asignaciones es la fuente del estado `evaluated`.
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

  /// Un solo borrador aunque se califiquen varios criterios a la vez.
  Future<String?> _ensureDraft() {
    final existing = state.draftId;
    if (existing != null) return Future.value(existing);
    return _draftRequest ??= _createDraft().whenComplete(() {
      _draftRequest = null;
    });
  }

  Future<String?> _createDraft() async {
    final repo = _ref.read(teachingEvaluationRepositoryProvider);
    final created = await repo.createDraft(assignmentId);
    var draft = created.dataOrNull;
    var failure = created.failureOrNull;
    if (failure is ConflictFailure) {
      // Ya existía (otro dispositivo o un intento previo): se reutiliza.
      final found = await repo.findDraft(assignmentId);
      draft = found.dataOrNull;
      failure = found.failureOrNull;
    }
    if (!mounted) return null;
    if (draft == null || draft.submitted) {
      state = state.copyWith(
        errorMessage: failure != null
            ? _saveFailureMessage(failure)
            : 'Esta evaluación ya fue enviada. Actualiza la lista de docentes.',
      );
      return null;
    }
    state = state.copyWith(draftId: draft.id);
    return draft.id;
  }

  Future<bool> _reconcile() async {
    try {
      final result = await _ref.read(getMyTeachingAssignmentsUseCaseProvider)();
      if (!mounted) return false;
      final assignments = result.dataOrNull;
      if (assignments != null) {
        _ref
            .read(teachingListControllerProvider.notifier)
            .replaceFromServer(assignments);
      }
      final assignment =
          assignments?.where((item) => item.id == assignmentId).firstOrNull;
      if (assignment?.evaluated == true) {
        _ref
            .read(teachingListControllerProvider.notifier)
            .markEvaluated(assignmentId);
        state = state.copyWith(
          checkingStatus: false,
          needsStatusCheck: false,
          confirmed: true,
          clearError: true,
        );
        return true;
      }
      if (assignment != null && assignment.canEvaluate) {
        state = state.copyWith(
          checkingStatus: false,
          needsStatusCheck: false,
          statusConfirmedPending: true,
          errorMessage:
              'El servidor confirma que sigue pendiente. Revisa tus respuestas y vuelve a enviarla.',
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
      if (!mounted) return false;
      state = state.copyWith(
        checkingStatus: false,
        needsStatusCheck: true,
        errorMessage:
            'No pudimos comprobar si se registró. Consulta el estado antes de volver a intentarlo.',
      );
      return false;
    }
  }

  bool _needsReconciliation(Failure failure) =>
      failure is TimeoutFailure ||
      failure is NetworkFailure ||
      failure is ServerFailure ||
      failure is ConflictFailure ||
      failure is UnknownFailure;

  String _saveFailureMessage(Failure failure) {
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return 'Sin conexión: tu respuesta no se guardó. Vuelve a marcarla.';
    }
    if (failure is ForbiddenFailure || failure is ValidationFailure) {
      // El backend explica el motivo (jornada cerrada, curso fuera de tu ciclo…).
      return failure.message;
    }
    return _submissionFailureMessage(failure);
  }

  String _submissionFailureMessage(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return 'Tu sesión venció. Inicia sesión de nuevo.';
    }
    if (failure is ForbiddenFailure) {
      return 'No tienes permiso para enviar esta evaluación.';
    }
    if (failure is ValidationFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Revisa tus respuestas antes de continuar.';
    }
    if (failure is NotFoundFailure) {
      return 'Esta asignación ya no está disponible. Actualiza la lista de docentes.';
    }
    return 'No pudimos enviar la evaluación. Revisa el estado antes de intentarlo de nuevo.';
  }
}

final evaluateTeacherControllerProvider = StateNotifierProvider.family<
    EvaluateTeacherController, EvaluateState, String>(
  (ref, assignmentId) => EvaluateTeacherController(ref, assignmentId),
);
