/// Estado de votación del JURY en una feria.
///
/// El backend devuelve:
///   { fair_id, fair_status, has_voted, voted_at }
///
/// Importante: NO contiene el proyecto elegido (anonimato).
class VotingState {
  final String fairId;
  final String fairStatus;
  final bool hasVoted;
  final DateTime? votedAt;

  const VotingState({
    required this.fairId,
    required this.fairStatus,
    required this.hasVoted,
    this.votedAt,
  });

  factory VotingState.empty({required String fairId, String fairStatus = 'OPEN'}) =>
      VotingState(
        fairId: fairId,
        fairStatus: fairStatus,
        hasVoted: false,
        votedAt: null,
      );
}

/// Resultado del voto recién emitido.
/// El backend devuelve { status: 'CAST', receipt_code }.
/// NO contiene el proyecto (anonimato).
class CastVoteReceipt {
  final String status;
  final String receiptCode;

  const CastVoteReceipt({required this.status, required this.receiptCode});
}
