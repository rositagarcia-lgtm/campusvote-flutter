import '../../../../core/errors/result.dart';
import '../entities/eligibility_status.dart';
import '../entities/voting_receipt.dart';
import '../entities/voting_session.dart';
import '../repositories/voting_repository.dart';

class ValidateVotingEligibilityUseCase {
  ValidateVotingEligibilityUseCase(this._repo);
  final VotingRepository _repo;

  Future<Result<EligibilityStatus>> call(String electionId) =>
      _repo.validateEligibility(electionId);
}

class CreateVotingSessionUseCase {
  CreateVotingSessionUseCase(this._repo);
  final VotingRepository _repo;

  Future<Result<VotingSession>> call(
    String electionId, {
    String? votingToken,
  }) {
    return _repo.createVotingSession(electionId, votingToken: votingToken);
  }
}

class CastVoteUseCase {
  CastVoteUseCase(this._repo);
  final VotingRepository _repo;

  Future<Result<VotingReceipt>> call({
    required String sessionId,
    required List<String> optionIds,
    required Map<String, dynamic> rawSelections,
  }) {
    return _repo.castVote(
      sessionId: sessionId,
      optionIds: optionIds,
      rawSelections: rawSelections,
    );
  }
}

class GetVotingReceiptUseCase {
  GetVotingReceiptUseCase(this._repo);
  final VotingRepository _repo;
  Future<Result<VotingReceipt>> call(String receiptCode) =>
      _repo.verifyReceipt(receiptCode);
}

class GetVotingSessionUseCase {
  GetVotingSessionUseCase(this._repo);
  final VotingRepository _repo;
  Future<Result<VotingSession>> call(String sessionId) =>
      _repo.getVotingSession(sessionId);
}