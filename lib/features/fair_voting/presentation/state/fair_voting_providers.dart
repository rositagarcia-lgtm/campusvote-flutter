import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/repositories/fair_voting_repository_impl.dart';
import '../../domain/repositories/fair_voting_repository.dart';
import '../../domain/usecases/fair_voting_usecases.dart';

final fairVotingRepositoryProvider = Provider<FairVotingRepository>((ref) {
  return FairVotingRepositoryImpl(ref.watch(apiClientProvider));
});

final getMyAssignedFairsUseCaseProvider = Provider(
  (ref) => GetMyAssignedFairsUseCase(ref.watch(fairVotingRepositoryProvider)),
);
final getMyAssignedFairDetailUseCaseProvider = Provider(
  (ref) => GetMyAssignedFairDetailUseCase(
      ref.watch(fairVotingRepositoryProvider)),
);
final getFairProjectsUseCaseProvider = Provider(
  (ref) => GetFairProjectsUseCase(ref.watch(fairVotingRepositoryProvider)),
);
final getFairProjectDetailUseCaseProvider = Provider(
  (ref) => GetFairProjectDetailUseCase(ref.watch(fairVotingRepositoryProvider)),
);
final getFairRubricUseCaseProvider = Provider(
  (ref) => GetFairRubricUseCase(ref.watch(fairVotingRepositoryProvider)),
);
final getMyRubricResponseUseCaseProvider = Provider(
  (ref) => GetMyRubricResponseUseCase(ref.watch(fairVotingRepositoryProvider)),
);
final saveMyRubricResponseUseCaseProvider = Provider(
  (ref) => SaveMyRubricResponseUseCase(ref.watch(fairVotingRepositoryProvider)),
);
final getVotingStatusUseCaseProvider = Provider(
  (ref) => GetVotingStatusUseCase(ref.watch(fairVotingRepositoryProvider)),
);
final castVoteUseCaseProvider = Provider(
  (ref) => CastVoteUseCase(ref.watch(fairVotingRepositoryProvider)),
);
