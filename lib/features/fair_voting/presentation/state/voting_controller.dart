import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/voting_state.dart';
import 'fair_voting_providers.dart';

class VotingPanelState {
  final bool loading;
  final VotingState? status;
  final bool casting;
  final CastVoteReceipt? receipt;
  final String? errorMessage;

  const VotingPanelState({
    this.loading = false,
    this.status,
    this.casting = false,
    this.receipt,
    this.errorMessage,
  });

  VotingPanelState copyWith({
    bool? loading,
    VotingState? status,
    bool? casting,
    CastVoteReceipt? receipt,
    String? errorMessage,
    bool clearError = false,
    bool clearReceipt = false,
  }) =>
      VotingPanelState(
        loading: loading ?? this.loading,
        status: status ?? this.status,
        casting: casting ?? this.casting,
        receipt: clearReceipt ? null : (receipt ?? this.receipt),
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  bool get hasVoted => status?.hasVoted ?? false;
}

class VotingPanelController extends StateNotifier<VotingPanelState> {
  VotingPanelController(this._ref, this._fairId)
      : super(const VotingPanelState(loading: true)) {
    load();
  }

  final Ref _ref;
  final String _fairId;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true, clearReceipt: true);
    final res = await _ref.read(getVotingStatusUseCaseProvider)(_fairId);
    res.when(
      success: (data) {
        state = state.copyWith(loading: false, status: data);
      },
      failure: (f) {
        state = state.copyWith(loading: false, errorMessage: f.message);
      },
    );
  }

  Future<bool> castVote(String projectId) async {
    state = state.copyWith(casting: true, clearError: true, clearReceipt: true);
    final res = await _ref.read(castVoteUseCaseProvider)(
      fairId: _fairId,
      projectId: projectId,
    );
    return res.when(
      success: (receipt) {
        // Tras emitir voto, refrescar status para reflejar has_voted=true.
        state = state.copyWith(
          casting: false,
          receipt: receipt,
          status: VotingState(
            fairId: _fairId,
            fairStatus: state.status?.fairStatus ?? 'OPEN',
            hasVoted: true,
            votedAt: DateTime.now(),
          ),
        );
        return true;
      },
      failure: (f) {
        state = state.copyWith(casting: false, errorMessage: f.message);
        return false;
      },
    );
  }
}

final votingPanelControllerProvider = StateNotifierProvider.family<
    VotingPanelController, VotingPanelState, String>(
  (ref, fairId) => VotingPanelController(ref, fairId),
);
