import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ballot.dart';
import '../../domain/entities/voting_session.dart';
import 'voting_providers.dart';

class BallotState {
  final bool loading;
  final Ballot? ballot;
  final String? sessionId;
  final VotingSession? session;
  final Map<String, List<String>> selections; // ballotPositionId -> optionIds
  final bool submitting;
  final String? errorMessage;

  const BallotState({
    this.loading = false,
    this.ballot,
    this.sessionId,
    this.session,
    this.selections = const {},
    this.submitting = false,
    this.errorMessage,
  });

  BallotState copyWith({
    bool? loading,
    Ballot? ballot,
    String? sessionId,
    VotingSession? session,
    Map<String, List<String>>? selections,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return BallotState(
      loading: loading ?? this.loading,
      // Los campos de Ballot no son nulos: copiarlos uno a uno con ?? era
      // código muerto.
      ballot: ballot ?? this.ballot,
      sessionId: clearSession ? null : (sessionId ?? this.sessionId),
      session: clearSession ? null : (session ?? this.session),
      selections: selections ?? this.selections,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool isSelected(String ballotPositionId, String optionId) {
    return selections[ballotPositionId]?.contains(optionId) ?? false;
  }

  bool get isComplete {
    final ballot = this.ballot;
    if (ballot == null) return false;
    for (final pos in ballot.positions) {
      if (!selections.containsKey(pos.id)) return false;
    }
    return true;
  }
}

class BallotController extends StateNotifier<BallotState> {
  BallotController(this._ref, this._electionId)
      : super(const BallotState(loading: true));

  final Ref _ref;
  final String _electionId;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    final res = await _ref.read(getBallotUseCaseProvider)(_electionId);
    res.when(
      success: (ballot) {
        state = state.copyWith(loading: false, ballot: ballot);
      },
      failure: (f) {
        state = state.copyWith(loading: false, errorMessage: f.message);
      },
    );
  }

  void toggleOption(String ballotPositionId, String optionId,
      {bool single = true}) {
    final current = Map<String, List<String>>.from(state.selections);
    final list = List<String>.from(current[ballotPositionId] ?? const []);
    if (list.contains(optionId)) {
      list.remove(optionId);
    } else {
      if (single) {
        list.clear();
      }
      list.add(optionId);
    }
    current[ballotPositionId] = list;
    state = state.copyWith(selections: current, clearError: true);
  }

  /// Devuelve los optionIds agregados para enviar al backend.
  List<String> allSelectedOptionIds() {
    return state.selections.values.expand((e) => e).toList();
  }

  Map<String, dynamic> selectionsPayload() {
    return {
      for (final entry in state.selections.entries)
        entry.key: entry.value,
    };
  }
}

final ballotControllerProvider = StateNotifierProvider.family<
    BallotController, BallotState, String>(
  (ref, id) => BallotController(ref, id),
);