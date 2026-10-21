part of '../evaluate_controller.dart';

mixin _EvaluateTeacherPersistence on StateNotifier<EvaluateState> {
  Ref get ref;
  String get assignmentId;
  Future<String?>? get draftRequest;
  set draftRequest(Future<String?>? value);
  Future<String?> _ensureDraft() {
    final existing = state.draftId;
    if (existing != null) return Future.value(existing);
    return draftRequest ??= _createDraft().whenComplete(() {
      draftRequest = null;
    });
  }

  Future<String?> _createDraft() async {
    final repo = ref.read(teachingEvaluationRepositoryProvider);
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
            ? saveFailureMessage(failure)
            : 'Esta evaluación ya fue enviada. Actualiza la lista de docentes.',
      );
      return null;
    }
    state = state.copyWith(draftId: draft.id);
    return draft.id;
  }

  Future<bool> _reconcile() async {
    try {
      final result = await ref.read(getMyTeachingAssignmentsUseCaseProvider)();
      if (!mounted) return false;
      final assignments = result.dataOrNull;
      if (assignments != null) {
        ref
            .read(teachingListControllerProvider.notifier)
            .replaceFromServer(assignments);
      }
      final assignment =
          assignments?.where((item) => item.id == assignmentId).firstOrNull;
      if (assignment?.evaluated == true) {
        ref
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
}
