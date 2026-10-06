// jury_providers.dart — punto único de acceso a los providers del jurado.
//
// Cada provider vive en su propio archivo dentro de `providers/`, agrupado por
// módulo (datos, ferias, formularios y progreso). Este archivo solo reexporta:
// las pantallas y widgets siguen importando `jury_providers.dart`.

export 'data/jury_dependencies.dart';
export 'fairs/jury_fair_providers.dart';
export 'forms/jury_declaration_provider.dart';
export 'forms/jury_rubric_provider.dart';
export 'forms/jury_voting_provider.dart';
export 'progress/jury_progress_provider.dart';
