// forms/jury_rubric_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/repositories/jury_repository.dart';
import '../data/jury_dependencies.dart';
import '../fairs/jury_fair_providers.dart';
import '../jury_state.dart';
import '../progress/jury_progress_provider.dart';

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
    state = state.copyWith(
      loading: true,
      clearError: true,
    );
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
      // Finalizar una rúbrica cambia "Mi progreso" y el listado de evaluaciones.
      if (finalize) _ref.invalidate(juryProgressProvider(args.fairId));
      if (finalize) _ref.invalidate(myEvaluationsProvider(args.fairId));
      return true;
    } catch (e) {
      state = state.copyWith(saving: false, errorMessage: describeJuryError(e));
      return false;
    }
  }
}
