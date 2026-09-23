/// Sesión de votación iniciada por el backend.
class VotingSession {
  final String sessionId;
  final String electionId;
  final String status;
  final DateTime? startedAt;
  final DateTime? expiresAt;

  const VotingSession({
    required this.sessionId,
    required this.electionId,
    required this.status,
    this.startedAt,
    this.expiresAt,
  });

  bool get isActive => status == 'STARTED';
  bool get isCast => status == 'CAST';
  bool get isFinished => status == 'FINALIZED' || status == 'CLOSED';
}