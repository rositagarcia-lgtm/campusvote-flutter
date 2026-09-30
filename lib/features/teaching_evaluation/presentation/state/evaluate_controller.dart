import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'teaching_evaluation_providers.dart';
import 'teaching_list_controller.dart';

class EvaluateState {
  final bool submitting;
  final String? errorMessage;

  const EvaluateState({this.submitting = false, this.errorMessage});

  EvaluateState copyWith({
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) =>
      EvaluateState(
        submitting: submitting ?? this.submitting,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

/// Controla el envío de la evaluación de una asignación concreta.
class EvaluateTeacherController extends StateNotifier<EvaluateState> {
  EvaluateTeacherController(this._ref, this.assignmentId)
      : super(const EvaluateState());

  final Ref _ref;
  final String assignmentId;

  Future<bool> submit({required int score, String? comment}) async {
    state = state.copyWith(submitting: true, clearError: true);
    final res = await _ref.read(evaluateTeacherUseCaseProvider)(
      assignmentId: assignmentId,
      score: score,
      comment: comment,
    );
    final ok = res.when(
      success: (_) => true,
      failure: (f) {
        state = state.copyWith(submitting: false, errorMessage: f.message);
        return false;
      },
    );
    if (ok) {
      state = state.copyWith(submitting: false, clearError: true);
      // Marca la asignación como evaluada en la lista compartida.
      _ref
          .read(teachingListControllerProvider.notifier)
          .markEvaluated(assignmentId);
    }
    return ok;
  }
}

final evaluateTeacherControllerProvider =
    StateNotifierProvider.family<EvaluateTeacherController, EvaluateState,
        String>(
  (ref, assignmentId) => EvaluateTeacherController(ref, assignmentId),
);