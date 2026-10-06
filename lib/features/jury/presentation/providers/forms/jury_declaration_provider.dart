// forms/jury_declaration_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/jury_models.dart';
import '../data/jury_dependencies.dart';
import '../jury_state.dart';
import '../progress/jury_progress_provider.dart';

/// Declaración de imparcialidad del jurado para una feria.
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
      // "Mi progreso" resume la participación: sin invalidarlo seguiría
      // mostrando la declaración como pendiente al volver a esa pantalla.
      _ref.invalidate(juryProgressProvider(fairId));
      return true;
    } catch (e) {
      state =
          state.copyWith(submitting: false, errorMessage: describeJuryError(e));
      return false;
    }
  }
}
