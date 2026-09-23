import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/fair_rubric.dart';
import '../../domain/entities/rubric_response.dart';
import 'fair_voting_providers.dart';

/// Estado de la pantalla de rúbrica para un proyecto.
/// Combina la rúbrica configurada (ADMIN) + la hoja del JURY.
class RubricState {
  final bool loading;
  final bool saving;
  final FairRubric? rubric;
  final RubricResponse? response;

  /// Mapa criterionId → checked (true/false). Copia local que se sincroniza
  /// con `response` después de cada PUT.
  final Map<String, bool> answers;

  final String? errorMessage;

  const RubricState({
    this.loading = false,
    this.saving = false,
    this.rubric,
    this.response,
    this.answers = const {},
    this.errorMessage,
  });

  RubricState copyWith({
    bool? loading,
    bool? saving,
    FairRubric? rubric,
    RubricResponse? response,
    Map<String, bool>? answers,
    String? errorMessage,
    bool clearError = false,
  }) =>
      RubricState(
        loading: loading ?? this.loading,
        saving: saving ?? this.saving,
        rubric: rubric ?? this.rubric,
        response: response ?? this.response,
        answers: answers ?? this.answers,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  bool get submitted => response?.submitted ?? false;
  bool get hasRubric => rubric != null && rubric!.activeCriteria.isNotEmpty;

  /// Cantidad de criterios marcados (checked=true) en el estado local.
  int get checkedCount => answers.values.where((c) => c).length;

  /// ¿Están TODOS los criterios activos respondidos (checked o unchecked)?
  /// Para finalizar, el JURY debe responder todos los activos.
  bool get allActiveAnswered {
    final active = rubric?.activeCriteria ?? const [];
    if (active.isEmpty) return false;
    for (final c in active) {
      if (!answers.containsKey(c.id)) return false;
    }
    return true;
  }
}

class RubricController extends StateNotifier<RubricState> {
  RubricController(this._ref, this._fairId, this._projectId)
      : super(const RubricState(loading: true)) {
    load();
  }

  final Ref _ref;
  final String _fairId;
  final String _projectId;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    final rubricRes =
        await _ref.read(getFairRubricUseCaseProvider)(_fairId);
    final rubric = rubricRes.when(
      success: (r) => r,
      failure: (_) => null,
    );
    if (rubric == null || rubric.activeCriteria.isEmpty) {
      state = state.copyWith(
        loading: false,
        rubric: rubric,
        answers: const {},
        response: null,
      );
      return;
    }
    final responseRes = await _ref.read(getMyRubricResponseUseCaseProvider)(
      fairId: _fairId,
      projectId: _projectId,
    );
    final response = responseRes.when(
      success: (r) => r,
      failure: (_) => RubricResponse.empty(
        fairId: _fairId,
        projectId: _projectId,
        rubricId: rubric.id,
      ),
    );

    state = state.copyWith(
      loading: false,
      rubric: rubric,
      response: response,
      answers: Map<String, bool>.from(response.answers),
    );
  }

  /// Toggle local del check de un criterio. No se persiste hasta `save()`.
  /// Si la rúbrica ya está finalizada, ignora el cambio (no se puede editar).
  void toggleAnswer(String criterionId, bool checked) {
    if (state.submitted) return;
    if (!state.answers.containsKey(criterionId) &&
        !(state.rubric?.activeCriteria.any((c) => c.id == criterionId) ?? false)) {
      return; // criterio inexistente
    }
    final next = Map<String, bool>.from(state.answers);
    next[criterionId] = checked;
    state = state.copyWith(answers: next);
  }

  /// Marca TODOS los criterios activos como checked=true (atajo).
  void markAllChecked() {
    if (state.submitted) return;
    final active = state.rubric?.activeCriteria ?? const [];
    final next = Map<String, bool>.from(state.answers);
    for (final c in active) {
      next[c.id] = true;
    }
    state = state.copyWith(answers: next);
  }

  /// Persiste (upsert). Si `finalize=true`, además cierra la hoja.
  /// Devuelve `true` si se guardó exitosamente.
  Future<bool> save({required bool finalize}) async {
    if (state.submitted && finalize) return false;
    if (state.rubric == null) return false;

    if (finalize && !state.allActiveAnswered) {
      state = state.copyWith(
        errorMessage:
            'Debes responder todos los criterios activos antes de finalizar.',
      );
      return false;
    }

    state = state.copyWith(saving: true, clearError: true);
    final res = await _ref.read(saveMyRubricResponseUseCaseProvider)(
      fairId: _fairId,
      projectId: _projectId,
      answers: state.answers,
      finalize: finalize,
    );
    return res.when(
      success: (updated) {
        state = state.copyWith(
          saving: false,
          response: updated,
          answers: Map<String, bool>.from(updated.answers),
        );
        return true;
      },
      failure: (f) {
        state = state.copyWith(saving: false, errorMessage: f.message);
        return false;
      },
    );
  }
}

final rubricControllerProvider = StateNotifierProvider.family<
    RubricController, RubricState, (String, String)>(
  (ref, args) => RubricController(ref, args.$1, args.$2),
);
