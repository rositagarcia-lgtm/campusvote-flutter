import '../../data/models/jury_models.dart';

/// Estados de las pantallas del panel de jurado.
///
/// Las pantallas de solo lectura usan `AsyncValue<T>` de Riverpod
/// (loading / data / error). Aquí viven las que además necesitan estado
/// mutable: la hoja de rúbrica, la votación y la declaración.

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

/// Estado de la pantalla de votación.
class VotingFormState {
  const VotingFormState({
    this.status,
    this.projects = const [],
    this.loading = true,
    this.submitting = false,
    this.requiresStatusRefresh = false,
    this.selectedProjectId,
    this.receipt,
    this.errorMessage,
  });

  final VotingStatusModel? status;
  final List<FairProjectModel> projects;
  final bool loading;

  /// Se pone en true ANTES del POST: el backend rechaza el segundo voto con
  /// 409, así que el botón no puede reactivarse hasta tener respuesta.
  final bool submitting;

  /// Una respuesta perdida del POST puede ocultar que el servidor ya registró
  /// el voto. En ese caso se exige reconciliar con GET antes de permitir otro.
  final bool requiresStatusRefresh;
  final String? selectedProjectId;
  final VoteReceiptModel? receipt;
  final String? errorMessage;

  /// Regla 5: bloqueada si la feria no está abierta o ya voted.
  bool get canVote =>
      (status?.canVote ?? false) &&
      !submitting &&
      !requiresStatusRefresh &&
      receipt == null;
  bool get hasVoted => status?.hasVoted ?? false;

  VotingFormState copyWith({
    VotingStatusModel? status,
    List<FairProjectModel>? projects,
    bool? loading,
    bool? submitting,
    bool? requiresStatusRefresh,
    String? selectedProjectId,
    VoteReceiptModel? receipt,
    String? errorMessage,
    bool clearSelection = false,
    bool clearError = false,
  }) =>
      VotingFormState(
        status: status ?? this.status,
        projects: projects ?? this.projects,
        loading: loading ?? this.loading,
        submitting: submitting ?? this.submitting,
        requiresStatusRefresh:
            requiresStatusRefresh ?? this.requiresStatusRefresh,
        selectedProjectId: clearSelection
            ? null
            : (selectedProjectId ?? this.selectedProjectId),
        receipt: receipt ?? this.receipt,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

/// Estado de la pantalla de declaración de jurado.
class DeclarationFormState {
  const DeclarationFormState({
    this.status,
    this.statement = '',
    this.loading = true,
    this.submitting = false,
    this.errorMessage,
  });

  final JuryDeclarationStatusModel? status;
  final String statement;
  final bool loading;
  final bool submitting;
  final String? errorMessage;

  bool get signed => status?.signed ?? false;
  bool get canSubmit => statement.trim().isNotEmpty && !submitting && !signed;

  DeclarationFormState copyWith({
    JuryDeclarationStatusModel? status,
    String? statement,
    bool? loading,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) =>
      DeclarationFormState(
        status: status ?? this.status,
        statement: statement ?? this.statement,
        loading: loading ?? this.loading,
        submitting: submitting ?? this.submitting,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}
