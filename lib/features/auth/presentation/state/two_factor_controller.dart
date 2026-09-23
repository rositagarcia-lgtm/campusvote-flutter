import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/totp.dart';
import 'auth_providers.dart';

class TwoFactorState {
  final bool loading;
  final TotpStatus status;
  final bool submitting;
  final String? errorMessage;

  const TwoFactorState({
    this.loading = false,
    this.status = const TotpStatus(enabled: false, backupCodesRemaining: 0),
    this.submitting = false,
    this.errorMessage,
  });

  TwoFactorState copyWith({
    bool? loading,
    TotpStatus? status,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TwoFactorState(
      loading: loading ?? this.loading,
      status: status ?? this.status,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TwoFactorController extends StateNotifier<TwoFactorState> {
  TwoFactorController(this._ref) : super(const TwoFactorState(loading: true));

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    final res = await _ref.read(getTwoFactorStatusUseCaseProvider)();
    res.when(
      success: (status) {
        state = state.copyWith(loading: false, status: status);
      },
      failure: (f) {
        state = state.copyWith(loading: false, errorMessage: f.message);
      },
    );
  }

  Future<void> refresh() async => load();

  void markEnabled() {
    state = state.copyWith(
      status: const TotpStatus(enabled: true, backupCodesRemaining: 10),
    );
  }

  void markDisabled() {
    state = state.copyWith(
      status: const TotpStatus(enabled: false, backupCodesRemaining: 0),
    );
  }
}

final twoFactorControllerProvider =
    StateNotifierProvider<TwoFactorController, TwoFactorState>(
  (ref) => TwoFactorController(ref),
);