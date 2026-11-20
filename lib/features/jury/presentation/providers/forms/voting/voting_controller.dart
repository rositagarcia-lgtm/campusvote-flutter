// voting_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/jury_models.dart';
import '../../../../data/datasources/jury_remote_datasource.dart';
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
        repo.getFairProjects(fairId),
        repo.getMyEvaluations(fairId: fairId, page: 1, limit: 200),
      ]);
      // El repositorio entrega los proyectos paginados: tratarlos como
      // `List` lanzaba un TypeError y la pantalla mostraba "No se pudo
      // completar la operación" sin llegar a cargar la votación.
      final firstProjects = results[1] as PaginatedResult<FairProjectModel>;
      final allProjects = [...firstProjects.items];
      for (var page = 2; page <= firstProjects.totalPages; page++) {
        allProjects.addAll(
            (await repo.getFairProjects(fairId, page: page)).items);
      }
      final status = results[0] as VotingStatusModel;
      final firstEvals = results[2] as PaginatedResult<JuryEvaluationSummaryModel>;
      final allEvals = [...firstEvals.items];
      for (var page = 2; page <= firstEvals.totalPages; page++) {
        allEvals.addAll(
          (await repo.getMyEvaluations(fairId: fairId, page: page, limit: 200))
              .items,
        );
      }

      // Calcular progreso de rúbricas por categoría
      final categoryProgress = calculateCategoryProgress(
        projects: allProjects.where((p) => p.status == 'APPROVED').toList(),
        evaluations: allEvals,
        categories: status.categories,
      );

      state = state.copyWith(
        loading: false,
        requiresStatusRefresh: false,
        evaluationsLoading: false,
        scores: extractMyScores(allEvals),
        status: status,
        // El jurado vota solo en su categoría.
        // Empieza por la primera categoría sin voto (excepción: varias).
        activeCategoryId: status.categories.isEmpty
            ? null
            : (status.categories.where((c) => !c.hasVoted).firstOrNull ??
                    status.categories.first)
                .id,
        // El servidor solo acepta votos por proyectos aprobados.
        projects:
            allProjects.where((p) => p.status == 'APPROVED').toList(growable: false),
        categoryProgress: categoryProgress,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        evaluationsLoading: false,
        errorMessage: describeJuryError(e),
      );
    }
  }

  /// Reconciliación ligera tras una respuesta ambigua del voto: no vuelve a
  /// solicitar proyectos para desbloquear una selección ya cargada, pero sí
  /// recalcula el progreso con las evaluaciones vigentes en el servidor.
  /// [preserveMessage] conserva el motivo del rechazo mientras se refresca.
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
        repo.getMyEvaluations(fairId: fairId, page: 1, limit: 200),
      ]);
      final status = results[0] as VotingStatusModel;
      final firstEvals = results[1] as PaginatedResult<JuryEvaluationSummaryModel>;
      final allEvals = [...firstEvals.items];
      for (var page = 2; page <= firstEvals.totalPages; page++) {
        allEvals.addAll(
          (await repo.getMyEvaluations(fairId: fairId, page: page, limit: 200))
              .items,
        );
      }

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
      // "Mi progreso" resume la participación: sin invalidarlo seguiría
      // mostrando el voto como pendiente al volver a esa pantalla.
      _ref.invalidate(juryProgressProvider(fairId));
      AppAnalytics.event('jury_vote_cast');
      AppHaptics.success();
      return true;
    } catch (e) {
      final message = describeJuryError(e);
      state = state.copyWith(
        submitting: false,
        requiresStatusRefresh: true,
        errorMessage: message,
      );
      // El POST pudo llegar al servidor aunque la respuesta se haya perdido.
      // Reconsultamos participación Y rúbricas antes de habilitar un reintento:
      // el backend es la autoridad y su progreso puede haber cambiado.
      await refreshStatus(preserveMessage: message);
      return false;
    }
  }
}