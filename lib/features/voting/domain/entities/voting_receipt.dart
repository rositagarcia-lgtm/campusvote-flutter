/// Comprobante del voto emitido (respuesta oficial del backend).
class VotingReceipt {
  final String receiptCode;
  final DateTime? castAt;
  final String? electionId;
  final String? electionTitle;
  final String? electionStatus;

  const VotingReceipt({
    required this.receiptCode,
    this.castAt,
    this.electionId,
    this.electionTitle,
    this.electionStatus,
  });

  bool get isValid =>
      electionId != null && electionStatus != null;
}