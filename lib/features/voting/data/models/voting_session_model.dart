import '../../domain/entities/voting_session.dart';

/// Modela la respuesta de:
/// - POST /api/voting/elections/:electionId/sessions  → { sessionId, electionId, status, message }
/// - GET  /api/voting/sessions/:id                   → { id, electionId, voterId,
///                                                        startedAt, completedAt, isSuccessful }
///
/// Ambos son camelCase; la entidad deriva `sessionId` del campo `id` cuando hace falta.
class VotingSessionModel extends VotingSession {
  const VotingSessionModel({
    required super.sessionId,
    required super.electionId,
    required super.status,
    super.startedAt,
    super.expiresAt,
  });

  static String _str(dynamic v) => (v ?? '').toString();

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  factory VotingSessionModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = _str(json['status']);
    String derivedStatus;
    if (rawStatus.isNotEmpty) {
      derivedStatus = rawStatus;
    } else if (json['completedAt'] != null) {
      derivedStatus = json['isSuccessful'] == true ? 'CAST' : 'CLOSED';
    } else if (json['startedAt'] != null) {
      derivedStatus = 'STARTED';
    } else {
      derivedStatus = 'UNKNOWN';
    }

    return VotingSessionModel(
      sessionId: _str(json['sessionId'] ?? json['session_id'] ?? json['id']),
      electionId: _str(json['electionId'] ?? json['election_id']),
      status: derivedStatus,
      startedAt: _parseDate(json['startedAt'] ?? json['started_at']),
      expiresAt: _parseDate(json['expiresAt'] ?? json['expires_at']),
    );
  }

  VotingSession toEntity() => this;
}