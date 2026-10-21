part of '../project_visuals.dart';

/// Etapas del recorrido de un proyecto, de la inscripción al cierre de feria.
enum ProjectStage { registered, review, approved, live, finished }

extension StudentProjectStage on StudentProject {
  ProjectStage get stage {
    if (status == 'SUBMITTED' || isRejected) return ProjectStage.review;
    if (!isApproved) return ProjectStage.registered;
    if (fair?.isClosed == true) return ProjectStage.finished;
    if (fair?.isOpen == true) return ProjectStage.live;
    return ProjectStage.approved;
  }

  /// Texto y tono del estado, siempre acompañados de ícono (no solo color).
  (String, AppTone, IconData) get statusBadge => switch (status) {
        'APPROVED' when fair?.isOpen == true => (
            'En feria',
            AppTone.success,
            PhosphorIconsFill.radioButton,
          ),
        'APPROVED' when fair?.isClosed == true => (
            'Feria finalizada',
            AppTone.neutral,
            PhosphorIconsRegular.sealCheck,
          ),
        'APPROVED' => (
            'Aprobado',
            AppTone.success,
            PhosphorIconsRegular.sealCheck
          ),
        'SUBMITTED' => (
            'En revisión',
            AppTone.warning,
            PhosphorIconsRegular.hourglassMedium
          ),
        'REJECTED' => (
            'Con observaciones',
            AppTone.danger,
            PhosphorIconsRegular.warningCircle
          ),
        'DRAFT_PENDING_STUDENT_CONFIRMATION' => (
            'Por confirmar',
            AppTone.info,
            PhosphorIconsRegular.notePencil,
          ),
        _ => ('Borrador', AppTone.neutral, PhosphorIconsRegular.pencilSimple),
      };
}

String projectRoleLabel(String? role) => switch (role) {
      'EXPOSITOR' => 'Expositor',
      'COLLABORATOR' => 'Colaborador',
      'OWNER' => 'Responsable',
      _ => 'Integrante',
    };

/// Portada del proyecto. Sin imagen, un bloque con el color institucional y
