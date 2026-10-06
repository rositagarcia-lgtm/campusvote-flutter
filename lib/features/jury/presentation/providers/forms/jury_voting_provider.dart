// forms/jury_voting_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/jury_models.dart';
import '../data/jury_dependencies.dart';
import '../jury_state.dart';
import '../progress/jury_progress_provider.dart';

/// Estado de votación + proyectos votables de la feria.
final votingFormProvider =
    StateNotifierProvider.family<VotingFormController, VotingFormState, String>(
        VotingFormController.new);

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
    );
    try {
      final repo = _ref.read(juryRepositoryProvider);
      final results = await Future.wait([
        repo.getVotingStatus(fairId),
        repo.getFairProjects(fairId),
      ]);
      state = state.copyWith(
        loading: false,
        requiresStatusRefresh: false,
        status: results[0] as VotingStatusModel,
        projects: results[1] as List<FairProjectModel>,
      );
    } catch (e) {
      state =
          state.copyWith(loading: false, errorMessage: describeJuryError(e));
    }
  }

  /// Reconciliación ligera tras una respuesta ambigua del voto: no vuelve a
  /// solicitar proyectos para desbloquear una selección ya cargada.
  Future<void> refreshStatus() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final status =
          await _ref.read(juryRepositoryProvider).getVotingStatus(fairId);
      state = state.copyWith(
        loading: false,
        status: status,
        requiresStatusRefresh: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        requiresStatusRefresh: true,
        errorMessage: describeJuryError(e),
      );
    }
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
        status: VotingStatusModel(
          fairId: fairId,
          fairStatus: state.status?.fairStatus ?? FairStatus.open,
          hasVoted: true,
        ),
        clearSelection: true,
      );
      // "Mi progreso" resume la participación: sin invalidarlo seguiría
      // mostrando el voto como pendiente al volver a esa pantalla.
      _ref.invalidate(juryProgressProvider(fairId));
      return true;
    } catch (e) {
      final message = describeJuryError(e);
      state = state.copyWith(
        submitting: false,
        requiresStatusRefresh: true,
        errorMessage: message,
      );
      // El POST pudo llegar al servidor aunque la respuesta se haya perdido.
      // Consultamos participación antes de habilitar cualquier reintento.
      try {
        final status =
            await _ref.read(juryRepositoryProvider).getVotingStatus(fairId);
        state = state.copyWith(
          status: status,
          requiresStatusRefresh: false,
          errorMessage: status.hasVoted ? null : message,
        );
      } catch (_) {
        // Sin respuesta del estado, la selección queda bloqueada hasta que el
        // usuario recupere conectividad y fuerce una nueva consulta.
      }
      return false;
    }
  }
}
