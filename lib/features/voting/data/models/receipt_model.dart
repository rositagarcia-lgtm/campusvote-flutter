import '../../domain/entities/voting_receipt.dart';

/// Modela la respuesta de:
/// - POST /api/voting/sessions/:sessionId/cast  → { receiptCode, status, message }
/// - GET  /public/verify-receipt/:code         → { valid, electionId, electionTitle,
///                                                  electionStatus, castAt, payloadHash }
class ReceiptModel extends VotingReceipt {
  const ReceiptModel({
    required super.receiptCode,
    super.castAt,
    super.electionId,
    super.electionTitle,
    super.electionStatus,
  });

  static String _str(dynamic v) => (v ?? '').toString();
  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      receiptCode: _str(json['receiptCode'] ?? json['receipt_code']),
      castAt: _parseDate(json['castAt'] ?? json['cast_at']),
      electionId: (json['electionId'] ?? json['election_id'])?.toString(),
      electionTitle:
          (json['electionTitle'] ?? json['election_title'])?.toString(),
      electionStatus:
          (json['electionStatus'] ?? json['election_status'])?.toString(),
    );
  }

  VotingReceipt toEntity() => this;
}