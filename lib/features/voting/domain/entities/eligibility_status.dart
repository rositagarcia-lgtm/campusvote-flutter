/// Posible estado de elegibilidad del usuario frente a una elección.
///
/// Refleja los mensajes que devuelve el backend al iniciar la sesión o
/// al emitir el voto. La fuente de verdad siempre es el backend.
enum VotingEligibility {
  eligible,
  notEligible,
  alreadyVoted,
  electionClosed,
  electionNotStarted,
  sessionExpired,
  unknown,
}

class EligibilityStatus {
  final VotingEligibility state;
  final String? message;
  const EligibilityStatus({required this.state, this.message});

  factory EligibilityStatus.fromErrorMessage(String message) {
    final m = message.toLowerCase();
    if (m.contains('ya emitió') || m.contains('ya ha sido utilizado')) {
      return const EligibilityStatus(state: VotingEligibility.alreadyVoted);
    }
    if (m.contains('no está abierta') || m.contains('finalizada')) {
      return const EligibilityStatus(state: VotingEligibility.electionClosed);
    }
    if (m.contains('elegible')) {
      return const EligibilityStatus(state: VotingEligibility.notEligible);
    }
    if (m.contains('sesión') && m.contains('expirada')) {
      return const EligibilityStatus(state: VotingEligibility.sessionExpired);
    }
    return EligibilityStatus(state: VotingEligibility.unknown, message: message);
  }
}