// rubric_state.dart

import '../../data/models/jury_models.dart';

/// Identifica un proyecto dentro de una feria (clave de los providers family).
class RubricArgs {
  const RubricArgs({required this.fairId, required this.projectId});

  final String fairId;
  final String projectId;

  @override
  bool operator ==(Object other) =>
      other is RubricArgs &&
      other.fairId == fairId &&
      other.projectId == projectId;

  @override
  int get hashCode => Object.hash(fairId, projectId);
}

/// Estado del formulario de rúbrica (checklist).
class RubricFormState {
  const RubricFormState({
    this.loading = true,
    this.saving = false,
    this.evaluation,
    this.answers = const {},
    this.errorMessage,
    this.successMessage,
  });

  final bool loading;
  final bool saving;
  final RubricEvaluationModel? evaluation;

  /// `criterionId → checked`. El backend exige TODOS los criterios activos
  /// cuando `finalize = true` (`normalizeChecklistResponses`).
  final Map<String, bool> answers;

  final String? errorMessage;
  final String? successMessage;

  bool get hasData => evaluation != null;
  bool get submitted => evaluation?.submitted ?? false;
  bool get locked => submitted || saving;
  int get totalCriteria => evaluation?.totalCriteria ?? 0;
  int get checkedCount => answers.values.where((c) => c).length;

  /// ¿Respondidos todos los criterios activos (marked or unmarked)?
  bool get allAnswered {
    final criteria =
        evaluation?.rubric.criteria ?? const <RubricCriterionModel>[];
    if (criteria.isEmpty) return false;
    return criteria.every((c) => answers.containsKey(c.id));
  }

  /// Solo se habilita "Finalizar" con cobertura total.
  bool get canFinalize => allAnswered && !locked;

  RubricFormState copyWith({
    bool? loading,
    bool? saving,
    RubricEvaluationModel? evaluation,
    Map<String, bool>? answers,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) =>
      RubricFormState(
        loading: loading ?? this.loading,
        saving: saving ?? this.saving,
        evaluation: evaluation ?? this.evaluation,
        answers: answers ?? this.answers,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        successMessage:
            clearSuccess ? null : (successMessage ?? this.successMessage),
      );
}