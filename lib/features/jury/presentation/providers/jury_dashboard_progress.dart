import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'jury_providers.dart';

/// Avance real: proyectos finalizados / proyectos evaluables en ferias abiertas.
/// Si una consulta falla, la vista deja el porcentaje sin confirmar.
class JuryDashboardProgress {
  const JuryDashboardProgress({required this.completed, required this.total});

  final int completed;
  final int total;

  int? get percentage =>
      total == 0 ? null : ((completed / total) * 100).round();
}

final juryDashboardProgressProvider =
    FutureProvider<JuryDashboardProgress>((ref) async {
  final assignments = await ref.watch(juryDashboardProvider.future);
  final openIds =
      assignments.where((fair) => fair.isOpen).map((fair) => fair.fairId);
  final progress = await Future.wait([
    for (final fairId in openIds)
      ref.watch(juryProgressProvider(fairId).future),
  ]);
  return JuryDashboardProgress(
    completed: progress.fold(0, (sum, item) => sum + item.completedProjects),
    total: progress.fold(0, (sum, item) => sum + item.totalProjects),
  );
});
