/// Modelos del panel de jurado.
///
/// Contrato real del backend (`src/modules/juryAssignments`,
/// `fairEvaluations`, `fairVoting`, `fairResults`): snake_case → camelCase.
/// `fromJson`/`toJson` manuales, sin freezed.
library;

export 'jury/common.dart';
export 'jury/fair_models.dart';
export 'jury/rubric_models.dart';
export 'jury/voting_models.dart';
export 'jury/results_models.dart';
