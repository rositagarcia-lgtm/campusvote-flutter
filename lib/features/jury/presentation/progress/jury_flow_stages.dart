import '../../../../core/theme/app_icons.dart';
import '../../data/models/jury_models.dart';
import 'jury_flow.dart';

/// Construye las etapas del flujo a partir del progreso del backend.
///
/// Cada método lee únicamente `JuryProgressModel`: no recalcula estados que el
/// modelo ya resuelve y no consulta endpoints nuevos.
abstract final class JuryFlowStages {
  static List<JuryFlowStage> of(
    JuryProgressModel progress, {
    DateTime? votedAt,
  }) =>
      [
        _fair(progress),
        _projects(progress),
        _evaluation(progress),
        _voting(progress, votedAt),
        _declaration(progress),
        _closing(progress),
      ];

  /// Texto con el conteo de proyectos en singular o plural.
  static String projects(int count) =>
      '$count proyecto${count == 1 ? '' : 's'}';

  static JuryFlowStage _fair(JuryProgressModel progress) {
    return JuryFlowStage(
      key: 'fair',
      icon: progress.fairStatus == FairStatus.closed
          ? PhosphorIconsRegular.calendarX
          : PhosphorIconsRegular.calendarCheck,
      title: 'Feria asignada',
      description: switch (progress.fairStatus) {
        FairStatus.open => 'La feria está abierta para tu categoría.',
        FairStatus.closed => 'La feria ya cerró y no admite participaciones.',
        FairStatus.draft => 'La feria todavía no está abierta.',
        FairStatus.unknown => 'El estado de la feria está sin confirmar.',
      },
      status: progress.fairStatus == FairStatus.draft
          ? JuryStageStatus.pending
          : JuryStageStatus.done,
    );
  }

  static JuryFlowStage _projects(JuryProgressModel progress) {
    final total = progress.totalProjects;
    final hasProjects = total > 0;
    return JuryFlowStage(
      key: 'projects',
      icon: PhosphorIconsRegular.folders,
      title: 'Proyectos asignados',
      description: hasProjects
          ? 'La organización publicó ${projects(total)}'
              ' aprobado${total == 1 ? '' : 's'} para tu categoría.'
          : 'Todavía no hay proyectos aprobados para tu categoría.',
      status: hasProjects ? JuryStageStatus.done : JuryStageStatus.pending,
      action: hasProjects ? JuryStageAction.projects : null,
    );
  }

  static JuryFlowStage _evaluation(JuryProgressModel progress) {
    final total = progress.totalProjects;
    final pending = progress.pendingProjects;
    final hasProjects = total > 0;
    final done = progress.isComplete;
    final JuryStageStatus status;
    final String description;
    if (!hasProjects) {
      status = JuryStageStatus.blocked;
      description = 'No hay proyectos que calificar en esta feria.';
    } else if (done) {
      status = JuryStageStatus.done;
      description = 'Finalizaste la rúbrica de ${projects(total)} asignados.';
    } else if (progress.completedProjects > 0) {
      status = JuryStageStatus.active;
      description = '${projects(pending)} pendiente${pending == 1 ? '' : 's'} '
          'de rúbrica. Calificar por criterio no registra tu voto.';
    } else {
      status = JuryStageStatus.pending;
      description = 'Abre un proyecto y califica los criterios de su rúbrica.';
    }

    return JuryFlowStage(
      key: 'evaluation',
      icon: PhosphorIconsRegular.listChecks,
      title: 'Evaluación de proyectos',
      description: description,
      status: status,
      action: hasProjects ? JuryStageAction.projects : null,
    );
  }

  static JuryFlowStage _voting(
    JuryProgressModel progress,
    DateTime? votedAt,
  ) {
    final voted = progress.hasVoted;
    final isOpen = progress.fairStatus == FairStatus.open;
    final String description;
    if (voted) {
      description =
          'Tu voto quedó registrado de forma anónima. El voto es único.';
    } else if (!isOpen) {
      description =
          'La votación solo está habilitada mientras la feria está abierta.';
    } else {
      description = 'Elige un proyecto y emite tu voto oficial. Es un paso '
          'independiente de la rúbrica.';
    }

    return JuryFlowStage(
      key: 'voting',
      icon: PhosphorIconsRegular.checkSquareOffset,
      title: 'Votación oficial',
      description: description,
      status: voted
          ? JuryStageStatus.done
          : (isOpen ? JuryStageStatus.pending : JuryStageStatus.blocked),
      action: (voted || isOpen) ? JuryStageAction.voting : null,
      noteAt: voted ? votedAt : null,
    );
  }

  static JuryFlowStage _declaration(JuryProgressModel progress) {
    final signed = progress.declaration != null;
    final isOpen = progress.fairStatus == FairStatus.open;
    final String description;
    if (signed) {
      description =
          'Tu declaración de imparcialidad está registrada en esta feria.';
    } else if (!isOpen) {
      description = 'La declaración solo se acepta con la feria abierta.';
    } else {
      description = 'Declara que no tienes conflicto de interés con los '
          'proyectos. Queda registrada con tu usuario y la fecha.';
    }

    return JuryFlowStage(
      key: 'declaration',
      icon: signed
          ? PhosphorIconsRegular.clipboardText
          : PhosphorIconsRegular.signature,
      title: 'Declaración de jurado',
      description: description,
      status: signed
          ? JuryStageStatus.done
          : (isOpen ? JuryStageStatus.pending : JuryStageStatus.blocked),
      action: (signed || isOpen) ? JuryStageAction.declaration : null,
      noteAt: progress.declaration?.signedAt,
    );
  }

  static JuryFlowStage _closing(JuryProgressModel progress) {
    final closed = progress.fairStatus == FairStatus.closed;
    return JuryFlowStage(
      key: 'closing',
      icon: PhosphorIconsFill.lockSimple,
      title: 'Cierre de la feria',
      description: closed
          ? 'La feria pasó a estado cerrado.'
          : 'Se habilita cuando la feria pase a estado cerrado.',
      status: closed ? JuryStageStatus.done : JuryStageStatus.blocked,
    );
  }
}
