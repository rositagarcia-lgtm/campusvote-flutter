// voting_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/jury_models.dart';
import '../../../../domain/repositories/jury_repository.dart';
import '../../data/jury_dependencies.dart'
    show describeJuryError, juryRepositoryProvider;
import '../../../state/jury_state.dart';
import '../../progress/jury_progress_provider.dart'
    show juryProgressProvider;
import '../../../../../../core/feedback/app_haptics.dart'
    show AppHaptics;
import '../../../../../../core/analytics/app_analytics.dart'
    show AppAnalytics;
import 'voting_progress_calculator.dart'
    show calculateCategoryProgress, extractMyScores;

/// Controlador del estado de votación + proyectos votables de la feria.
class VotingFormController extends StateNotifier<VotingFormState> {
  VotingFormController(this._ref, this.fairId)
      : super(const VotingFormState()) {
    load();
  }

  final Ref _ref;
  final String fairId;

  Future<List<FairProjectModel>> _fetchAllProjects(JuryRepository repo) async {
    final first = await repo.getFairProjects(fairId);
    if (first.totalPages <= 1) return first.items;

    final rest = await Future.wait([
      for (var page = 2; page <= first.totalPages; page++)
        repo.getFairProjects(fairId, page: page),
    ]);
    return [
      ...first.items,
      for (final p in rest) ...p.items,
    ];
  }

  Future<List<JuryEvaluationSummaryModel>> _fetchAllEvaluations(
    JuryRepository repo,
  ) async {
    final first = await repo.getMyEvaluations(
      fairId: fairId,
      page: 1,
      limit: 100,
    );
    if (first.totalPages <= 1) return first.items;

    final rest = await Future.wait([
      for (var page = 2; page <= first.totalPages; page++)
        repo.getMyEvaluations(fairId: fairId, page: page, limit: 100),
    ]);
    return [
      ...first.items,
      for (final e in rest) ...e.items,
    ];
  }

  Future<void> load() async {
    state = state.copyWith(
      loading: true,
      requiresStatusRefresh: true,
      clearError: true,
      evaluationsLoading: true,
    );
    try {
      final repo = _ref.read(juryRepositoryProvider);
      final results = await Future.wait([
        repo.getVotingStatus(fairId),
        _fetchAllProjects(repo),
        _fetchAllEvaluations(repo),
      ]);
      if (!mounted) return;

      final status = results[0] as VotingStatusModel;
      final allProjects = results[1] as List<FairProjectModel>;
      final allEvals = results[2] as List<JuryEvaluationSummaryModel>;

      // El servidor solo acepta votos por proyectos aprobados.
      final approvedProjects = allProjects
          .where((p) => p.status == 'APPROVED')
          .toList(growable: false);

      final categoryProgress = calculateCategoryProgress(
        projects: approvedProjects,
        evaluations: allEvals,
        categories: status.categories,
      );

      state = state.copyWith(
        loading: false,
        requiresStatusRefresh: false,
        evaluationsLoading: false,
        scores: extractMyScores(allEvals),
        status: status,
        activeCategoryId: status.categories.isEmpty
            ? null
            : (status.categories.where((c) => !c.hasVoted).firstOrNull ??
                    status.categories.first)
                .id,
        projects: approvedProjects,
        categoryProgress: categoryProgress,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        evaluationsLoading: false,
        errorMessage: describeJuryError(e),
      );
    }
  }

  /// Reconciliación ligera tras una respuesta ambigua del voto.
  Future<void> refreshStatus({String? preserveMessage}) async {
    state = state.copyWith(
      loading: true,
      clearError: preserveMessage == null,
      errorMessage: preserveMessage,
      evaluationsLoading: true,
    );
    try {
      final repo = _ref.read(juryRepositoryProvider);
      final results = await Future.wait([
        repo.getVotingStatus(fairId),
        _fetchAllEvaluations(repo),
      ]);
      if (!mounted) return;

      final status = results[0] as VotingStatusModel;
      final allEvals = results[1] as List<JuryEvaluationSummaryModel>;

      final categoryProgress = calculateCategoryProgress(
        projects: state.projects,
        evaluations: allEvals,
        categories: status.categories,
      );

      state = state.copyWith(
        loading: false,
        status: status,
        requiresStatusRefresh: false,
        evaluationsLoading: false,
        scores: extractMyScores(allEvals),
        categoryProgress: categoryProgress,
        clearError: status.hasVoted,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        evaluationsLoading: false,
        requiresStatusRefresh: true,
        errorMessage: preserveMessage ?? describeJuryError(e),
      );
    }
  }

  /// Cambia de categoría: solo entre las asignadas al jurado (excepción).
  void selectCategory(String categoryId) {
    if (state.submitting || !state.categories.any((c) => c.id == categoryId)) {
      return;
    }
    state = state.copyWith(
      activeCategoryId: categoryId,
      clearSelection: true,
      clearReceipt: true,
      clearError: true,
    );
  }

  void select(String projectId) {
    if (!state.canVote) return;
    state = state.copyWith(selectedProjectId: projectId, clearError: true);
  }

  /// Idempotencia (regla 8): `submitting` bloquea el botón desde el primer tap
  /// y solo se rearma con un 2xx o un error no terminal.
  Future<bool> submit() async {
    final projectId = state.selectedProjectId;
    if (!state.canVote || projectId == null) return false;
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final receipt =
          await _ref.read(juryRepositoryProvider).castVote(fairId, projectId);
      if (!mounted) return true;

      state = state.copyWith(
        submitting: false,
        receipt: receipt,
        status: state.status?.withCategoryVoted(state.activeCategoryId) ??
            VotingStatusModel(
              fairId: fairId,
              fairStatus: FairStatus.open,
              hasVoted: true,
            ),
        clearSelection: true,
      );
      _ref.invalidate(juryProgressProvider(fairId));
      AppAnalytics.event('jury_vote_cast');
      AppHaptics.success();
      return true;
    } catch (e) {
      if (!mounted) return false;
      final message = describeJuryError(e);
      state = state.copyWith(
        submitting: false,
        requiresStatusRefresh: true,
        errorMessage: message,
      );
      await refreshStatus(preserveMessage: message);
      return false;
    }
  }
}