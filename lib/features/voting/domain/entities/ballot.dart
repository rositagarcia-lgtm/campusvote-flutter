import 'candidate_list.dart';
import 'election_position.dart';

/// Boleta: conjunto de cargos con sus opciones (listas o blank/void).
class Ballot {
  final String id;
  final String electionId;
  final int version;
  final List<BallotPosition> positions;

  const Ballot({
    required this.id,
    required this.electionId,
    required this.version,
    required this.positions,
  });
}

class BallotPosition {
  final String id; // ballotPositionId
  final ElectionPosition position;
  final int orderIndex;
  final List<BallotOption> options;
  final bool allowsBlank;
  final bool allowsVoid;

  const BallotPosition({
    required this.id,
    required this.position,
    required this.orderIndex,
    required this.options,
    this.allowsBlank = false,
    this.allowsVoid = false,
  });
}

class BallotOption {
  final String id; // optionId (lo que se envía al backend en selections)
  final BallotOptionType type;
  final String label;
  final CandidateList? list;
  final List<Candidate> candidates;

  const BallotOption({
    required this.id,
    required this.type,
    required this.label,
    this.list,
    this.candidates = const [],
  });
}

enum BallotOptionType { candidateList, blank, none }