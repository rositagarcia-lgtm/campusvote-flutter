import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/election.dart';
import '../../domain/entities/eligibility_status.dart';
import 'voting_providers.dart';

class ElectionDetailState {
  final bool loading;
  final Election? election;
  final EligibilityStatus eligibility;
  final String? errorMessage;

  const ElectionDetailState({
    this.loading = false,
    this.election,
    this.eligibility = const EligibilityStatus(state: VotingEligibility.unknown),
    this.errorMessage,
  });

  ElectionDetailState copyWith({
    bool? loading,
    Election? election,
    EligibilityStatus? eligibility,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ElectionDetailState(
      loading: loading ?? this.loading,
      election: election ?? this.election,
      eligibility: eligibility ?? this.eligibility,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ElectionDetailController extends StateNotifier<ElectionDetailState> {
  ElectionDetailController(this._ref, this._electionId)
      : super(const ElectionDetailState(loading: true));

  final Ref _ref;
  final String _electionId;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    final detailRes =
        await _ref.read(getElectionDetailUseCaseProvider)(_electionId);
    detailRes.when(
      success: (election) {
        state = state.copyWith(loading: false, election: election);
        _checkEligibility();
      },
      failure: (f) {
        state = state.copyWith(loading: false, errorMessage: f.message);
      },
    );
  }

  Future<void> _checkEligibility() async {
    final res =
        await _ref.read(validateVotingEligibilityUseCaseProvider)(_electionId);
    res.when(
      success: (status) {
        state = state.copyWith(eligibility: status);
      },
      failure: (f) {
        state = state.copyWith(
          eligibility: EligibilityStatus.fromErrorMessage(f.message),
        );
      },
    );
  }
}

final electionDetailControllerProvider = StateNotifierProvider.family<
    ElectionDetailController, ElectionDetailState, String>(
  (ref, id) => ElectionDetailController(ref, id),
);