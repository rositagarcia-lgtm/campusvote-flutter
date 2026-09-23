import '../../../../core/errors/result.dart';
import '../entities/election.dart';
import '../repositories/voting_repository.dart';

class GetAvailableElectionsUseCase {
  GetAvailableElectionsUseCase(this._repo);
  final VotingRepository _repo;

  Future<Result<PaginatedElections>> call({
    int page = 1,
    int limit = 20,
    String? status,
  }) {
    return _repo.getAvailableElections(
      page: page,
      limit: limit,
      status: status,
    );
  }
}

class GetElectionDetailUseCase {
  GetElectionDetailUseCase(this._repo);
  final VotingRepository _repo;
  Future<Result<Election>> call(String electionId) =>
      _repo.getElectionDetail(electionId);
}