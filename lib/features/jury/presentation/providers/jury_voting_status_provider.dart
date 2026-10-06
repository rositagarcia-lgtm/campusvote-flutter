import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/jury_models.dart';
import 'jury_providers.dart';

/// Fuente autoritativa para saber si el jurado ya votó, sin revelar su voto.
final juryVotingStatusProvider =
    FutureProvider.autoDispose.family<VotingStatusModel, String>((ref, fairId) {
  return ref.watch(juryRepositoryProvider).getVotingStatus(fairId);
});
