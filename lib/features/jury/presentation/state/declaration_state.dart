// declaration_state.dart

import '../../data/models/jury_models.dart';

/// Estado de la pantalla de declaración de jurado.
class DeclarationFormState {
  const DeclarationFormState({
    this.status,
    this.statement = '',
    this.loading = true,
    this.submitting = false,
    this.errorMessage,
  });

  final JuryDeclarationStatusModel? status;
  final String statement;
  final bool loading;
  final bool submitting;
  final String? errorMessage;

  bool get signed => status?.signed ?? false;
  bool get canSubmit => statement.trim().isNotEmpty && !submitting && !signed;

  DeclarationFormState copyWith({
    JuryDeclarationStatusModel? status,
    String? statement,
    bool? loading,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) =>
      DeclarationFormState(
        status: status ?? this.status,
        statement: statement ?? this.statement,
        loading: loading ?? this.loading,
        submitting: submitting ?? this.submitting,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}