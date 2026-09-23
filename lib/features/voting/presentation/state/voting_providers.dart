import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/repositories/voting_repository_impl.dart';
import '../../domain/repositories/voting_repository.dart';
import '../../domain/usecases/ballot_usecases.dart';
import '../../domain/usecases/get_ballot_usecase.dart';
import '../../domain/usecases/get_elections_usecases.dart';

final votingRepositoryProvider = Provider<VotingRepository>((ref) {
  return VotingRepositoryImpl(ref.watch(apiClientProvider));
});

// ── Consulta de elecciones ──────────────────────────────────────────

final getAvailableElectionsUseCaseProvider = Provider(
  (ref) => GetAvailableElectionsUseCase(ref.watch(votingRepositoryProvider)),
);
final getElectionDetailUseCaseProvider = Provider(
  (ref) => GetElectionDetailUseCase(ref.watch(votingRepositoryProvider)),
);

// ── Votación ────────────────────────────────────────────────────────
// Antes estos providers devolvían un `_NoopUsecase` que respondía siempre
// "Funcionalidad no disponible": la app compilaba, pero nadie podía votar.
// Los casos de uso reales seguían escritos y sus rutas existen en el
// backend, así que aquí se vuelven a conectar.

final getBallotUseCaseProvider = Provider(
  (ref) => GetBallotUseCase(ref.watch(votingRepositoryProvider)),
);
final validateVotingEligibilityUseCaseProvider = Provider(
  (ref) => ValidateVotingEligibilityUseCase(ref.watch(votingRepositoryProvider)),
);
final createVotingSessionUseCaseProvider = Provider(
  (ref) => CreateVotingSessionUseCase(ref.watch(votingRepositoryProvider)),
);
final castVoteUseCaseProvider = Provider(
  (ref) => CastVoteUseCase(ref.watch(votingRepositoryProvider)),
);
final getVotingReceiptUseCaseProvider = Provider(
  (ref) => GetVotingReceiptUseCase(ref.watch(votingRepositoryProvider)),
);
final getVotingSessionUseCaseProvider = Provider(
  (ref) => GetVotingSessionUseCase(ref.watch(votingRepositoryProvider)),
);
