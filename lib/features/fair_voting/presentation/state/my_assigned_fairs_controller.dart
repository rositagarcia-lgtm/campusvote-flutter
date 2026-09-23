import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/fair_assignment.dart';
import 'fair_voting_providers.dart';

class MyAssignedFairsState {
  final bool loading;
  final List<FairAssignment> items;
  final String? errorMessage;

  const MyAssignedFairsState({
    this.loading = false,
    this.items = const [],
    this.errorMessage,
  });

  MyAssignedFairsState copyWith({
    bool? loading,
    List<FairAssignment>? items,
    String? errorMessage,
    bool clearError = false,
  }) =>
      MyAssignedFairsState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  bool get isEmpty => items.isEmpty && !loading;
}

class MyAssignedFairsController extends StateNotifier<MyAssignedFairsState> {
  MyAssignedFairsController(this._ref)
      : super(const MyAssignedFairsState(loading: true));

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    final res = await _ref.read(getMyAssignedFairsUseCaseProvider)();
    res.when(
      success: (page) {
        state = state.copyWith(loading: false, items: page.items);
      },
      failure: (f) {
        state = state.copyWith(loading: false, errorMessage: f.message);
      },
    );
  }

  Future<void> refresh() async => load();
}

final myAssignedFairsControllerProvider =
    StateNotifierProvider<MyAssignedFairsController, MyAssignedFairsState>(
  (ref) => MyAssignedFairsController(ref),
);