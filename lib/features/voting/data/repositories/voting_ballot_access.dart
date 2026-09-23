import '../../../../core/config/endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/ballot.dart';
import '../../domain/entities/eligibility_status.dart';
import '../models/ballot_model.dart';
import '../models/election_model.dart';
import 'voting_api_mapper.dart';

/// Capa de acceso a boleta activa + elegibilidad.
class VotingBallotAccess {
  VotingBallotAccess(this._readClient);
  final dynamic Function() _readClient;

  Future<Result<Ballot>> getActiveBallot(String electionId) async {
    final client = _readClient();
    try {
      final res = await client.get(ApiEndpoints.activeBallot(electionId));
      final r = VotingApiMapper.wrap<Map<String, dynamic>>(
        res.data,
        (raw) => raw as Map<String, dynamic>,
      );
      if (!r.success || r.data == null) {
        return FailureResult(VotingApiMapper.toFailure(r.error?.message));
      }
      // El backend solo devuelve {id, version, generatedAt}; cargamos
      // posiciones y opciones en un segundo paso.
      final header = r.data!;
      final ballotId =
          (header['id'] ?? header['ballotId'] ?? '').toString();
      if (ballotId.isEmpty) {
        return const FailureResult(NotFoundFailure(
          message: 'No hay boleta activa para esta elección.',
        ));
      }

      final positionsRes =
          await client.get(ApiEndpoints.ballotPositions(ballotId));
      final pr = VotingApiMapper.wrap<dynamic>(
        positionsRes.data,
        (raw) => raw,
      );
      final positions = pr.success
          ? (pr.data is List ? pr.data as List : const [])
          : const <dynamic>[];

      final ballot = BallotModel.fromJson({
        'id': ballotId,
        'electionId':
            (header['electionId'] ?? header['election_id'] ?? '').toString(),
        'version': (header['version'] ?? 1) as int,
        'positions': positions,
      }).toEntity();

      try {
        final rulesRes =
            await client.get(ApiEndpoints.electionRules(electionId));
        final rr = VotingApiMapper.wrap<Map<String, dynamic>>(
          rulesRes.data,
          (raw) => raw as Map<String, dynamic>,
        );
        if (rr.success && rr.data != null) {
          final enriched = ballot.positions.map((p) {
            return BallotPosition(
              id: p.id,
              position: p.position,
              orderIndex: p.orderIndex,
              options: p.options,
              allowsBlank: (rr.data!['allow_blank_vote'] ?? true) as bool,
              allowsVoid: (rr.data!['allow_null_vote'] ?? true) as bool,
            );
          }).toList();
          return Success(Ballot(
            id: ballot.id,
            electionId: ballot.electionId,
            version: ballot.version,
            positions: enriched,
          ));
        }
      } catch (_) {}
      return Success(ballot);
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  Future<Result<EligibilityStatus>> getEligibility(String electionId) async {
    final client = _readClient();
    try {
      final res = await client.get(ApiEndpoints.electionById(electionId));
      final r = VotingApiMapper.wrap<Map<String, dynamic>>(
        res.data,
        (raw) => raw as Map<String, dynamic>,
      );
      if (!r.success || r.data == null) {
        return Success(EligibilityStatus(
          state: VotingEligibility.unknown,
          message: r.error?.message,
        ));
      }
      final m = ElectionModel.fromJson(r.data!);
      if (m.isClosed) {
        return const Success(
            EligibilityStatus(state: VotingEligibility.electionClosed));
      }
      if (m.isUpcoming) {
        return const Success(
            EligibilityStatus(state: VotingEligibility.electionNotStarted));
      }
      return const Success(
          EligibilityStatus(state: VotingEligibility.eligible));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }
}