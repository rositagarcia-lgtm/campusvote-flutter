import '../../../../core/errors/result.dart';
import '../entities/ballot.dart';
import '../entities/candidate_list.dart';
import '../entities/election.dart';
import '../entities/election_position.dart';
import '../entities/eligibility_status.dart';
import '../entities/voting_receipt.dart';
import '../entities/voting_session.dart';

class PaginatedElections {
  final List<Election> items;
  final int total;
  final int page;
  final int totalPages;
  const PaginatedElections({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}

abstract class VotingRepository {
  Future<Result<PaginatedElections>> getAvailableElections({
    int page = 1,
    int limit = 20,
    String? status,
  });

  Future<Result<Election>> getElectionDetail(String electionId);

  Future<Result<List<ElectionPosition>>> getElectionPositions(String electionId);

  Future<Result<List<CandidateList>>> getElectionCandidateLists(String electionId);

  Future<Result<List<Candidate>>> getElectionCandidacies(
    String electionId, {
    String? positionId,
    String? listId,
  });

  Future<Result<Ballot>> getActiveBallot(String electionId);

  Future<Result<EligibilityStatus>> validateEligibility(String electionId);

  Future<Result<VotingSession>> createVotingSession(
    String electionId, {
    String? votingToken,
  });

  Future<Result<VotingSession>> getVotingSession(String sessionId);

  Future<Result<VotingReceipt>> castVote({
    required String sessionId,
    required List<String> optionIds,
    required Map<String, dynamic> rawSelections,
  });

  Future<Result<VotingReceipt>> verifyReceipt(String receiptCode);
}