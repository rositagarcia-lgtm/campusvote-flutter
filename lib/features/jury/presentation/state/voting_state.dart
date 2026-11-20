// voting_state.dart

import '../../data/models/jury_models.dart';

/// Progreso de rúbricas por categoría para validación de votación.
class CategoryRubricProgress {
  const CategoryRubricProgress({
    required this.categoryId,
    required this.totalProjects,
    required this.completedRubrics,
    required this.pendingRubricProjectIds,
    this.categoryName,
    this.draftCount = 0,
  });

  final String categoryId;
  final String? categoryName;
  final int totalProjects;
  final int completedRubrics;
  final int draftCount;
  final List<String> pendingRubricProjectIds;

  bool get allSubmitted =>
      totalProjects > 0 && completedRubrics == totalProjects;
  int get pendingCount => pendingRubricProjectIds.length;

  CategoryRubricProgress copyWith({
    String? categoryName,
    int? totalProjects,
    int? completedRubrics,
    int? draftCount,
    List<String>? pendingRubricProjectIds,
  }) =>
      CategoryRubricProgress(
        categoryId: categoryId,
        categoryName: categoryName ?? this.categoryName,
        totalProjects: totalProjects ?? this.totalProjects,
        completedRubrics: completedRubrics ?? this.completedRubrics,
        draftCount: draftCount ?? this.draftCount,
        pendingRubricProjectIds:
            pendingRubricProjectIds ?? this.pendingRubricProjectIds,
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
    this.scores = const {},
    this.activeCategoryId,
    this.categoryProgress = const {},
    this.evaluationsLoading = true,
  });

  final VotingStatusModel? status;
  final List<FairProjectModel> projects;

  /// Categoría del jurado: vota solo en ella (un jurado, una categoría).
  final String? activeCategoryId;

  /// Progreso de rúbricas por categoría (clave: categoryId).
  /// Se calcula combinando proyectos asignados + evaluaciones persistidas.
  final Map<String, CategoryRubricProgress> categoryProgress;

  /// Indica si la carga de evaluaciones (myEvaluations) está en curso.
  /// Mientras true, se bloquea la votación por seguridad (fail-safe).
  final bool evaluationsLoading;

  List<VotingCategory> get categories => status?.categories ?? const [];

  VotingCategory? get activeCategory =>
      categories.where((c) => c.id == activeCategoryId).firstOrNull;

  /// Siguiente categoría asignada sin voto (solo jurados con excepción).
  VotingCategory? get nextPendingCategory => categories
      .where((c) => !c.hasVoted && c.id != activeCategoryId)
      .firstOrNull;

  /// Proyectos de la categoría activa (todos si el backend no envía categorías).
  List<FairProjectModel> get visibleProjects => categories.isEmpty
      ? projects
      : projects.where((p) => p.categoryId == activeCategoryId).toList();

  /// Progreso de rúbricas de la categoría activa.
  CategoryRubricProgress? get activeCategoryProgress =>
      activeCategoryId != null ? categoryProgress[activeCategoryId!] : null;

  /// ¿Todas las rúbricas de la categoría activa están finalizadas (submitted)?
  bool get activeCategoryAllRubricsSubmitted =>
      activeCategoryProgress?.allSubmitted ?? false;

  /// Proyectos de la categoría activa con rúbrica pendiente.
  List<FairProjectModel> get pendingRubricProjects {
    final progress = activeCategoryProgress;
    if (progress == null) return [];
    return visibleProjects
        .where((p) => progress.pendingRubricProjectIds.contains(p.id))
        .toList();
  }

  /// Puntaje (sobre 20) de las rúbricas que ESTE jurado finalizó, por
  /// proyecto. Solo el propio criterio: nunca el de otros jurados.
  final Map<String, double> scores;

  /// Proyectos de mayor a menor puntaje propio; los no evaluados van al final
  /// en orden alfabético. Es una ayuda para decidir, no un resultado oficial.
  List<FairProjectModel> get rankedProjects {
    final list = [...visibleProjects];
    list.sort((a, b) {
      final sa = scores[a.id];
      final sb = scores[b.id];
      if (sa != null && sb != null && sa != sb) return sb.compareTo(sa);
      if (sa != null && sb == null) return -1;
      if (sa == null && sb != null) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  /// Posición (1, 2, 3…) solo para proyectos con rúbrica finalizada.
  int? rankOf(String projectId) {
    if (!scores.containsKey(projectId)) return null;
    final scored = rankedProjects.where((p) => scores.containsKey(p.id));
    var position = 0;
    for (final p in scored) {
      position++;
      if (p.id == projectId) return position;
    }
    return null;
  }

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
  /// Requiere 100% rúbricas finalizadas (submitted == true) en la categoría activa.
  bool get canVote {
    final baseCanVote = categories.isEmpty
        ? (status?.canVote ?? false)
        : (status?.windowOpen ?? false) && !(activeCategory?.hasVoted ?? true);

    final rubricsComplete = activeCategoryId != null
        ? activeCategoryAllRubricsSubmitted
        : categoryProgress.isNotEmpty &&
            categoryProgress.values.every((p) => p.allSubmitted);

    return baseCanVote &&
        rubricsComplete &&
        !submitting &&
        !requiresStatusRefresh &&
        !evaluationsLoading &&
        receipt == null;
  }

  /// Ya votó en la categoría que está viendo (o en la feria, sin categorías).
  bool get hasVoted => categories.isEmpty
      ? (status?.hasVoted ?? false)
      : (activeCategory?.hasVoted ?? false);

  VotingFormState copyWith({
    VotingStatusModel? status,
    List<FairProjectModel>? projects,
    bool? loading,
    bool? submitting,
    bool? requiresStatusRefresh,
    String? selectedProjectId,
    VoteReceiptModel? receipt,
    String? errorMessage,
    Map<String, double>? scores,
    String? activeCategoryId,
    Map<String, CategoryRubricProgress>? categoryProgress,
    bool? evaluationsLoading,
    bool clearSelection = false,
    bool clearError = false,
    bool clearReceipt = false,
  }) =>
      VotingFormState(
        scores: scores ?? this.scores,
        activeCategoryId: activeCategoryId ?? this.activeCategoryId,
        status: status ?? this.status,
        projects: projects ?? this.projects,
        loading: loading ?? this.loading,
        submitting: submitting ?? this.submitting,
        requiresStatusRefresh:
            requiresStatusRefresh ?? this.requiresStatusRefresh,
        selectedProjectId: clearSelection
            ? null
            : (selectedProjectId ?? this.selectedProjectId),
        receipt: clearReceipt ? null : (receipt ?? this.receipt),
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        categoryProgress: categoryProgress ?? this.categoryProgress,
        evaluationsLoading: evaluationsLoading ?? this.evaluationsLoading,
      );
}