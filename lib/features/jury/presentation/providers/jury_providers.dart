import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/datasources/jury_remote_datasource.dart';
import '../../data/models/jury_models.dart';
import '../../data/repositories/jury_repository_impl.dart';
import '../../domain/repositories/jury_repository.dart';
import 'jury_state.dart';

// ── Inyección ──────────────────────────────────────────────────────────

final juryRemoteDataSourceProvider = Provider<JuryRemoteDataSource>((ref) {
  return JuryRemoteDataSource(ref.watch(apiClientProvider));
});

final juryRepositoryProvider = Provider<JuryRepository>((ref) {
  return JuryRepositoryImpl(ref.watch(juryRemoteDataSourceProvider));
});

/// Traduce [JuryApiException] a un mensaje presentable sin perder el código.
String describeJuryError(Object error) {
  if (error is JuryApiException) {
    if (error.isForbidden) {
      return 'Tu rol no tiene acceso a este recurso.';
    }
    return error.message;
  }
  return 'No se pudo completar la operación.';
}

// ── 1. Dashboard de ferias ──────────────────────────────────────────────

/// `GET /fairs/my-assignments`
final juryDashboardProvider =
    AsyncNotifierProvider<JuryDashboardNotifier, List<FairAssignmentModel>>(
        JuryDashboardNotifier.new);

class JuryDashboardNotifier extends AsyncNotifier<List<FairAssignmentModel>> {
  @override
  Future<List<FairAssignmentModel>> build() async {
    final page = await ref.read(juryRepositoryProvider).getMyAssignments();
    return page.items;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async =>
          (await ref.read(juryRepositoryProvider).getMyAssignments()).items,
    );
  }
}

// ── 2. Proyectos de la feria ────────────────────────────────────────────

/// `GET /fairs/:fairId/projects` — NO se re-filtra en Flutter (regla 7).
final fairProjectsProvider = AsyncNotifierProvider.family<FairProjectsNotifier,
    List<FairProjectModel>, String>(
  FairProjectsNotifier.new,
);

class FairProjectsNotifier
    extends FamilyAsyncNotifier<List<FairProjectModel>, String> {
  @override
  Future<List<FairProjectModel>> build(String fairId) async {
    return (await ref.read(juryRepositoryProvider).getFairProjects(fairId))
        .items;
  }
}

// ── 3. Formulario de rúbrica ────────────────────────────────────────────

/// Checklist mutable: el toggle de un criterio no debe recargar la hoja.
final rubricFormProvider = StateNotifierProvider.family<RubricFormController,
    RubricFormState, RubricArgs>(RubricFormController.new);

class RubricFormController extends StateNotifier<RubricFormState> {
  RubricFormController(this._ref, this.args) : super(const RubricFormState()) {
    load();
  }

  final Ref _ref;
  final RubricArgs args;

  JuryRepository get _repo => _ref.read(juryRepositoryProvider);

  /// Precarga la hoja del backend y arma `answers` con TODOS los criterios
  /// activos (marcados o no), que es lo que el PUT exige al finalizar.
  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final evaluation =
          await _repo.getProjectRubric(args.fairId, args.projectId);
      final answers = <String, bool>{
        for (final criterion in evaluation.rubric.criteria) criterion.id: false,
      };
      for (final response in evaluation.responses) {
        if (answers.containsKey(response.criterionId)) {
          answers[response.criterionId] = response.checked;
        }
      }
      state = state.copyWith(
        loading: false,
        evaluation: evaluation,
        answers: answers,
      );
    } catch (e) {
      state =
          state.copyWith(loading: false, errorMessage: describeJuryError(e));
    }
  }

  void toggle(String criterionId) {
    if (state.locked) return;
    state = state.copyWith(
      answers: {
        ...state.answers,
        criterionId: !(state.answers[criterionId] ?? false)
      },
      clearError: true,
      clearSuccess: true,
    );
  }

  /// `finalize: false` guarda borrador; `true` cierra la hoja y ya no admite
  /// cambios (el backend responde 409).
  Future<bool> save({required bool finalize}) async {
    if (state.locked) return false;
    if (finalize && !state.allAnswered) {
      state = state.copyWith(
        errorMessage: 'Responde todos los criterios antes de finalizar.',
      );
      return false;
    }
    state = state.copyWith(saving: true, clearError: true, clearSuccess: true);
    try {
      final saved = await _repo.saveProjectRubric(
        args.fairId,
        args.projectId,
        answers: state.answers,
        finalize: finalize,
      );
      state = state.copyWith(
        saving: false,
        evaluation: saved,
        successMessage:
            finalize ? 'Evaluación finalizada.' : 'Borrador guardado.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(saving: false, errorMessage: describeJuryError(e));
      return false;
    }
  }
}

// ── 4. Votación ─────────────────────────────────────────────────────────

/// Estado de votación + proyectos votables de la feria.
final votingFormProvider =
    StateNotifierProvider.family<VotingFormController, VotingFormState, String>(
        VotingFormController.new);

class VotingFormController extends StateNotifier<VotingFormState> {
  VotingFormController(this._ref, this.fairId)
      : super(const VotingFormState()) {
    load();
  }

  final Ref _ref;
  final String fairId;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = _ref.read(juryRepositoryProvider);
      final results = await Future.wait([
        repo.getVotingStatus(fairId),
        repo.getFairProjects(fairId),
      ]);
      state = state.copyWith(
        loading: false,
        status: results[0] as VotingStatusModel,
        projects: results[1] as List<FairProjectModel>,
      );
    } catch (e) {
      state =
          state.copyWith(loading: false, errorMessage: describeJuryError(e));
    }
  }

  void select(String projectId) {
    if (!state.canVote) return;
    state = state.copyWith(selectedProjectId: projectId, clearError: true);
  }

  /// Idempotencia (regla 8): `submitting` bloquea el botón desde el primer tap
  /// y solo se rearma con un 2xx o un error noterminal.
  Future<bool> submit() async {
    final projectId = state.selectedProjectId;
    if (!state.canVote || projectId == null) return false;
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final receipt =
          await _ref.read(juryRepositoryProvider).castVote(fairId, projectId);
      state = state.copyWith(
        submitting: false,
        receipt: receipt,
        status: VotingStatusModel(
          fairId: fairId,
          fairStatus: state.status?.fairStatus ?? FairStatus.open,
          hasVoted: true,
          votedAt: DateTime.now(),
        ),
        clearSelection: true,
      );
      return true;
    } catch (e) {
      state =
          state.copyWith(submitting: false, errorMessage: describeJuryError(e));
      return false;
    }
  }
}

// ── 5. Progreso del jurado ──────────────────────────────────────────────

/// `GET /fairs/my-progress/:fairId`
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

// ── 6. Declaración de jurado ────────────────────────────────────────────

final declarationFormProvider = StateNotifierProvider.family<
    DeclarationFormController,
    DeclarationFormState,
    String>(DeclarationFormController.new);

class DeclarationFormController extends StateNotifier<DeclarationFormState> {
  DeclarationFormController(this._ref, this.fairId)
      : super(const DeclarationFormState()) {
    load();
  }

  final Ref _ref;
  final String fairId;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final status =
          await _ref.read(juryRepositoryProvider).getDeclaration(fairId);
      state = state.copyWith(
        loading: false,
        status: status,
        statement: status.declaration?.statement ?? '',
      );
    } catch (e) {
      state =
          state.copyWith(loading: false, errorMessage: describeJuryError(e));
    }
  }

  void updateStatement(String value) {
    state = state.copyWith(statement: value, clearError: true);
  }

  Future<bool> submit() async {
    if (!state.canSubmit) return false;
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final declaration = await _ref
          .read(juryRepositoryProvider)
          .signDeclaration(fairId, state.statement.trim());
      state = state.copyWith(
        submitting: false,
        status: JuryDeclarationStatusModel(
          fairId: fairId,
          signed: true,
          declaration: declaration,
        ),
      );
      return true;
    } catch (e) {
      state =
          state.copyWith(submitting: false, errorMessage: describeJuryError(e));
      return false;
    }
  }
}

// ── 7. Resultados de la feria ───────────────────────────────────────────

/// `GET /fairs/:fairId/results` — ADMIN-only: un JURY recibe 403.
final fairResultsProvider =
    AsyncNotifierProvider.family<FairResultsNotifier, FairResultsModel, String>(
        FairResultsNotifier.new);

class FairResultsNotifier
    extends FamilyAsyncNotifier<FairResultsModel, String> {
  @override
  Future<FairResultsModel> build(String fairId) {
    return ref.read(juryRepositoryProvider).getResults(fairId);
  }
}

// ── 8. Mis evaluaciones ─────────────────────────────────────────────────

/// `GET /fairs/my-evaluations` (opcionalmente `?fair_id=`).
final myEvaluationsProvider = AsyncNotifierProvider.family<
    MyEvaluationsNotifier,
    List<JuryEvaluationSummaryModel>,
    String?>(MyEvaluationsNotifier.new);

class MyEvaluationsNotifier
    extends FamilyAsyncNotifier<List<JuryEvaluationSummaryModel>, String?> {
  @override
  Future<List<JuryEvaluationSummaryModel>> build(String? fairId) async {
    return (await ref
            .read(juryRepositoryProvider)
            .getMyEvaluations(fairId: fairId))
        .items;
  }
}
