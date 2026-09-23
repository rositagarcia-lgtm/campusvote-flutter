import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/election.dart';
import 'voting_providers.dart';

class VotingListState {
  final bool loading;
  final List<Election> active;
  final List<Election> upcoming;
  final List<Election> closed;
  final String? errorMessage;

  const VotingListState({
    this.loading = false,
    this.active = const [],
    this.upcoming = const [],
    this.closed = const [],
    this.errorMessage,
  });

  VotingListState copyWith({
    bool? loading,
    List<Election>? active,
    List<Election>? upcoming,
    List<Election>? closed,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VotingListState(
      loading: loading ?? this.loading,
      active: active ?? this.active,
      upcoming: upcoming ?? this.upcoming,
      closed: closed ?? this.closed,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isEmpty =>
      active.isEmpty && upcoming.isEmpty && closed.isEmpty && !loading;
}

class VotingListController extends StateNotifier<VotingListState> {
  VotingListController(this._ref) : super(const VotingListState());

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    final useCase = _ref.read(getAvailableElectionsUseCaseProvider);
    final result = await useCase(page: 1, limit: 100);
    result.when(
      success: (paginated) {
        final active = <Election>[];
        final upcoming = <Election>[];
        final closed = <Election>[];
        for (final e in paginated.items) {
          if (e.isOpen) {
            active.add(e);
          } else if (e.isUpcoming) {
            upcoming.add(e);
          } else {
            closed.add(e);
          }
        }
        state = state.copyWith(
          loading: false,
          active: active,
          upcoming: upcoming,
          closed: closed,
        );
      },
      failure: (f) {
        state = state.copyWith(loading: false, errorMessage: f.message);
      },
    );
  }

  Future<void> refresh() async => load();
}

final votingListControllerProvider =
    StateNotifierProvider<VotingListController, VotingListState>(
  (ref) => VotingListController(ref),
);