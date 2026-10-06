import 'package:flutter/material.dart';

import '../../data/models/jury_models.dart';
import 'jury_flow_stages.dart';

/// Estados de una etapa del flujo del jurado.
///
/// Se distinguen cuatro porque el jurado necesita leer de un vistazo qué falta:
/// `done` (completado), `active` (en progreso), `pending` (pendiente) y
/// `blocked` (bloqueado por el estado de la feria).
enum JuryStageStatus { done, active, pending, blocked }

/// Destino de una etapa del flujo.
///
/// Solo describe QUÉ se puede hacer; la ruta la resuelve la pantalla con el
/// router existente, así este archivo no depende de la navegación.
enum JuryStageAction { projects, voting, declaration }

/// Una etapa del flujo real del jurado dentro de una feria.
///
/// Solo contiene datos confirmados por el servidor: los conteos, los estados y
/// las fechas vienen de `JuryProgressModel` (y del estado de votación). Si un
/// dato no existe, la etapa lo omite en lugar de inventarlo.
class JuryFlowStage {
  const JuryFlowStage({
    required this.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    this.action,
    this.noteAt,
  });

  /// Identificador estable de la etapa.
  final String key;

  final IconData icon;
  final String title;

  /// Qué ocurre en esta etapa, en una frase.
  final String description;

  final JuryStageStatus status;

  /// Acción con la que el jurado puede avanzar esta etapa; si es nula, la
  /// etapa es solo información (todavía no hay nada que hacer).
  final JuryStageAction? action;

  /// Fecha real asociada al estado (voto, firma). Se formatea en la pantalla
  /// para respetar el idioma activo.
  final DateTime? noteAt;

  bool get isDone => status == JuryStageStatus.done;

  bool get isBlocked => status == JuryStageStatus.blocked;

  /// Etiqueta corta del estado. Nunca se comunica solo con color.
  String get statusLabel => switch (status) {
        JuryStageStatus.done => 'Completado',
        JuryStageStatus.active => 'En progreso',
        JuryStageStatus.pending => 'Pendiente',
        JuryStageStatus.blocked => 'Bloqueado',
      };
}

/// Vista del flujo del jurado: orden real de trabajo dentro de la feria.
///
/// ```
/// FERIA ASIGNADA → PROYECTOS ASIGNADOS → EVALUACIÓN CON RÚBRICA
///                → VOTACIÓN OFICIAL → DECLARACIÓN → CIERRE
/// ```
///
/// La rúbrica (evaluación por proyecto) y la votación oficial son etapas
/// distintas y nunca se suman: un puntaje de rúbrica no es un voto.
class JuryFlow {
  const JuryFlow({required this.progress, required this.stages});

  /// Deriva el flujo únicamente del progreso devuelto por el backend.
  /// [votedAt] es opcional: solo se muestra si el estado de votación lo trae.
  factory JuryFlow.fromProgress(
    JuryProgressModel progress, {
    DateTime? votedAt,
  }) =>
      JuryFlow(
        progress: progress,
        stages: JuryFlowStages.of(progress, votedAt: votedAt),
      );

  final JuryProgressModel progress;

  /// Etapas en el orden en que el jurado debe recorrerlas.
  final List<JuryFlowStage> stages;

  /// Etapa accionable que sigue: la primera pendiente o en progreso con acción.
  JuryFlowStage? get nextStage {
    for (final stage in stages) {
      if (stage.action != null && !stage.isDone && !stage.isBlocked) {
        return stage;
      }
    }
    return null;
  }

  /// Etapas que aún no están completadas (información, no un porcentaje).
  int get remainingSteps => stages.where((s) => !s.isDone).length;

  /// El jurado evaluó todos los proyectos, votó y firmó su declaración.
  bool get participationComplete =>
      progress.isComplete && progress.hasVoted && progress.declaration != null;

  /// Acción principal de la pantalla: un solo botón y solo si hay algo que
  /// hacer. Es `null` cuando el flujo ya está completo o bloqueado.
  JuryStageAction? get primaryAction => nextStage?.action;

  IconData? get primaryIcon => switch (primaryAction) {
        JuryStageAction.projects => Icons.fact_check_outlined,
        JuryStageAction.voting => Icons.how_to_vote_outlined,
        JuryStageAction.declaration => Icons.draw_outlined,
        null => null,
      };

  String? get primaryLabel => switch (primaryAction) {
        JuryStageAction.projects => 'Continuar evaluación',
        JuryStageAction.voting => 'Emitir voto oficial',
        JuryStageAction.declaration => 'Firmar declaración de jurado',
        null => null,
      };

  /// Situación actual en una frase. Nunca inventa un porcentaje combinado.
  String? get hint => switch (nextStage?.key) {
        'evaluation' when progress.pendingProjects > 0 =>
          'Te faltan ${JuryFlowStages.projects(progress.pendingProjects)} por '
              'calificar con rúbrica.',
        'evaluation' => 'Aún no registras ninguna evaluación.',
        'voting' => 'Tu voto oficial sigue pendiente.',
        'declaration' => 'Tu declaración de jurado sigue sin firmar.',
        _ => null,
      };
}
