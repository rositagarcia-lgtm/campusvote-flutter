import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/teacher_evaluation_form.dart';
import '../../domain/entities/teaching_assignment.dart';
import 'teaching_evaluation_providers.dart';
import 'evaluate_state.dart';
import 'evaluate_failure_messages.dart';
import 'teaching_list_controller.dart';

import '../../../../core/analytics/app_analytics.dart';

part 'evaluate_controller/evaluate_teacher_persistence.dart';

/// Evaluacion por criterios: carga rubrica y borrador, guarda respuestas.
/// Envia al final y verifica el estado si la red no confirma el envio.
class EvaluateTeacherController extends StateNotifier<EvaluateState>
    with _EvaluateTeacherPersistence {
  EvaluateTeacherController(this._ref, this.assignmentId)
      : super(const EvaluateState());

  final Ref _ref;
  @override
  final String assignmentId;
  Future<String?>? _draftRequest;

  @override
  Ref get ref => _ref;

  @override
  Future<String?>? get draftRequest => _draftRequest;

  @override
  set draftRequest(Future<String?>? value) => _draftRequest = value;

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
          ? saveFailureMessage(result!.failureOrNull!)
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
        errorMessage: submissionFailureMessage(failure),
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
    if (failure == null) AppAnalytics.event('teacher_evaluation_submitted');
    if (failure == null || needsReconciliation(failure)) {
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
      errorMessage: submissionFailureMessage(failure),
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
}

final evaluateTeacherControllerProvider = StateNotifierProvider.family<
    EvaluateTeacherController, EvaluateState, String>(
  (ref, assignmentId) => EvaluateTeacherController(ref, assignmentId),
);
