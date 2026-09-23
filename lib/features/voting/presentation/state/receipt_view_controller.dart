import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/voting_receipt.dart';
import 'voting_providers.dart';

/// Estado de la página de comprobante.
class ReceiptViewState {
  final bool loading;
  final VotingReceipt receipt;
  final String? errorMessage;
  const ReceiptViewState({
    required this.receipt,
    this.loading = false,
    this.errorMessage,
  });

  ReceiptViewState copyWith({
    bool? loading,
    VotingReceipt? receipt,
    String? errorMessage,
    bool clearError = false,
  }) =>
      ReceiptViewState(
        receipt: receipt ?? this.receipt,
        loading: loading ?? this.loading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

/// Carga los datos públicos del comprobante vía `verifyReceipt`.
/// No inventa timestamps: el `castAt` solo se conoce por esta vía.
class ReceiptViewController extends StateNotifier<ReceiptViewState> {
  ReceiptViewController(
    this._ref, {
    required String electionId,
    required String receiptCode,
  }) : super(ReceiptViewState(receipt: VotingReceipt(receiptCode: receiptCode))) {
    _load(electionId: electionId);
  }

  final Ref _ref;

  Future<void> _load({required String electionId}) async {
    final code = state.receipt.receiptCode;
    state = state.copyWith(loading: true, clearError: true);
    final res = await _ref.read(getVotingReceiptUseCaseProvider)(code);
    if (!mounted) return;
    res.when(
      success: (receipt) {
        state = state.copyWith(loading: false, receipt: receipt);
      },
      failure: (f) {
        state = state.copyWith(loading: false, errorMessage: f.message);
      },
    );
  }
}

final receiptViewControllerProvider = StateNotifierProvider.family<
    ReceiptViewController, ReceiptViewState,
    ({String electionId, String receiptCode})>(
  (ref, args) => ReceiptViewController(
    ref,
    electionId: args.electionId,
    receiptCode: args.receiptCode,
  ),
);