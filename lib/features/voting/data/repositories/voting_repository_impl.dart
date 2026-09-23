import '../../../../core/errors/result.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/payload_hasher.dart';
import '../../domain/entities/ballot.dart';
import '../../domain/entities/candidate_list.dart';
import '../../domain/entities/election.dart';
import '../../domain/entities/election_position.dart';
import '../../domain/entities/eligibility_status.dart';
import '../../domain/entities/voting_receipt.dart';
import '../../domain/entities/voting_session.dart';
import '../../domain/repositories/voting_repository.dart';
import 'voting_ballot_access.dart';
import 'voting_elections_access.dart';
import 'voting_session_cast.dart';

class VotingRepositoryImpl implements VotingRepository {
  VotingRepositoryImpl(this._client);

  final ApiClient _client;

  late final VotingElectionsAccess _elections = VotingElectionsAccess(() => _client);
  late final VotingBallotAccess _ballot = VotingBallotAccess(() => _client);
  late final VotingSessionAndCast _sessionCast =
      VotingSessionAndCast(() => _client);

  @override
  Future<Result<PaginatedElections>> getAvailableElections({
    int page = 1,
    int limit = 20,
    String? status,
  }) =>
      _elections.getAvailableElections(
        page: page,
        limit: limit,
        status: status,
      );

  @override
  Future<Result<Election>> getElectionDetail(String electionId) =>
      _elections.getElectionDetail(electionId);

  @override
  Future<Result<List<ElectionPosition>>> getElectionPositions(String id) =>
      _elections.getElectionPositions(id);

  @override
  Future<Result<List<CandidateList>>> getElectionCandidateLists(String id) =>
      _elections.getCandidateLists(id);

  @override
  Future<Result<List<Candidate>>> getElectionCandidacies(
    String id, {
    String? positionId,
    String? listId,
  }) =>
      _elections.getCandidacies(id, positionId: positionId, listId: listId);

  @override
  Future<Result<Ballot>> getActiveBallot(String electionId) =>
      _ballot.getActiveBallot(electionId);

  @override
  Future<Result<EligibilityStatus>> validateEligibility(String electionId) =>
      _ballot.getEligibility(electionId);

  @override
  Future<Result<VotingSession>> createVotingSession(
    String electionId, {
    String? votingToken,
  }) =>
      _sessionCast.startSession(electionId, votingToken: votingToken);

  @override
  Future<Result<VotingSession>> getVotingSession(String sessionId) =>
      _sessionCast.getSession(sessionId);

  @override
  Future<Result<VotingReceipt>> castVote({
    required String sessionId,
    required List<String> optionIds,
    required Map<String, dynamic> rawSelections,
  }) async {
    final selections = optionIds
        .map((id) => {'optionId': id})
        .toList(growable: false);
    final payload = {
      'selections': selections,
      ...rawSelections,
    };
    final hash = PayloadHasher.hash(payload);
    return _sessionCast.castVote(
      sessionId: sessionId,
      payloadHash: hash,
      encryptedPayload: hash,
      selections: selections,
    );
  }

  @override
  Future<Result<VotingReceipt>> verifyReceipt(String receiptCode) =>
      _sessionCast.verifyReceipt(receiptCode);
}