import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/fair_project.dart';
import 'fair_voting_providers.dart';

/// Lista de proyectos APPROVED de una feria, con anotación de
/// "rúbrica finalizada" por proyecto (estado local).
///
/// La rúbrica finalizada la marca cada proyecto individualmente cuando
/// el JURY finaliza su hoja de respuestas.
class FairProjectsState {
  final bool loading;
  final List<FairProject> projects;

  /// IDs de proyectos cuya rúbrica ya está finalizada.
  final Set<String> finalizedProjectIds;

  /// Conteo de hojas ya subidas (submittedAt != null).
  final Map<String, bool> submitted;

  final String? errorMessage;

  const FairProjectsState({
    this.loading = false,
    this.projects = const [],
    this.finalizedProjectIds = const {},
    this.submitted = const {},
    this.errorMessage,
  });

  FairProjectsState copyWith({
    bool? loading,
    List<FairProject>? projects,
    Set<String>? finalizedProjectIds,
    Map<String, bool>? submitted,
    String? errorMessage,
    bool clearError = false,
  }) =>
      FairProjectsState(
        loading: loading ?? this.loading,
        projects: projects ?? this.projects,
        finalizedProjectIds: finalizedProjectIds ?? this.finalizedProjectIds,
        submitted: submitted ?? this.submitted,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  /// Total de rúbricas completadas.
  int get completedCount =>
      projects.where((p) => finalizedProjectIds.contains(p.id)).length;

  /// ¿Todas las rúbricas están finalizadas?
  bool get allRubricsFinalized =>
      projects.isNotEmpty && completedCount == projects.length;
}

class FairProjectsController extends StateNotifier<FairProjectsState> {
  FairProjectsController(this._ref, this._fairId)
      : super(const FairProjectsState(loading: true)) {
    load();
  }

  final Ref _ref;
  final String _fairId;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    final res = await _ref.read(getFairProjectsUseCaseProvider)(_fairId);
    res.when(
      success: (page) {
        state = state.copyWith(
          loading: false,
          projects: page.items,
        );
      },
      failure: (f) {
        state = state.copyWith(loading: false, errorMessage: f.message);
      },
    );
  }

  /// Marca localmente un proyecto como "rúbrica finalizada" cuando el JURY
  /// confirma la finalización desde la pantalla de rúbrica.
  void markFinalized(String projectId, {bool submitted = true}) {
    final next = Set<String>.from(state.finalizedProjectIds)..add(projectId);
    final nextSubmitted = Map<String, bool>.from(state.submitted);
    nextSubmitted[projectId] = submitted;
    state = state.copyWith(
      finalizedProjectIds: next,
      submitted: nextSubmitted,
    );
  }
}

final fairProjectsControllerProvider = StateNotifierProvider.family<
    FairProjectsController, FairProjectsState, String>(
  (ref, fairId) => FairProjectsController(ref, fairId),
);
