import '../../../../core/errors/result.dart';
import '../entities/ballot.dart';
import '../repositories/voting_repository.dart';

/// Carga la boleta activa + posiciones + opciones (2 requests).
///
/// El backend separa:
/// - `GET /api/ballots/election/:id/active` → header
/// - `GET /api/ballots/:ballotId/positions` → posiciones con opciones anidadas
///
/// El repositorio se encarga del flujo y devuelve un [Ballot] ya ensamblado.
class GetBallotUseCase {
  GetBallotUseCase(this._repo);
  final VotingRepository _repo;
  Future<Result<Ballot>> call(String electionId) => _repo.getActiveBallot(electionId);
}