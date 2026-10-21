import '../../domain/entities/teacher_evaluation_form.dart';

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
