// progress/jury_progress_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/jury_models.dart';
import '../data/jury_dependencies.dart';

/// `GET /fairs/my-progress/:fairId`
///
/// Fuente única de la pantalla "Mi progreso": el backend ya devuelve conteos,
/// estado de la feria, voto y declaración.
final juryProgressProvider = AsyncNotifierProvider.family<JuryProgressNotifier,
    JuryProgressModel, String>(JuryProgressNotifier.new);

class JuryProgressNotifier
    extends FamilyAsyncNotifier<JuryProgressModel, String> {
  @override
  Future<JuryProgressModel> build(String fairId) {
    return ref.read(juryRepositoryProvider).getMyProgress(fairId);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(juryRepositoryProvider).getMyProgress(arg),
    );
  }
}
