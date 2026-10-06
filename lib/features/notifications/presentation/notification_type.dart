// notification_type.dart

import 'package:flutter/material.dart';

import '../../../core/widgets/app_status_chip.dart';

/// Familia de aviso a la que pertenece un tipo.
///
/// Es lo que decide si el aviso aparece en «Oficiales» o en «Feria y
/// proyectos»; los tipos que el backend añada después y todavía no conoce el
/// app quedan fuera de ambos filtros en vez de caer en uno por defecto.
enum NotificationCategory { official, fair }

/// Cómo se ve y cómo se nombra un tipo de aviso.
///
/// Un solo lugar para ícono, etiqueta y tono: antes cada vista tenía su propio
/// `switch`, así que el mismo aviso podía salir con un ícono en la tarjeta, otro
/// en el filtro y un tercero en la etiqueta.
class NotificationTypeDescriptor {
  const NotificationTypeDescriptor({
    required this.label,
    required this.icon,
    required this.tone,
    this.category,
  });

  /// Nombre corto del tipo; se muestra como sobretítulo de la tarjeta.
  final String label;

  final IconData icon;

  /// Tono de la casa (`AppTone`): el ícono, el sobretítulo y el punto de no
  /// leído se tiñen con el mismo color en claro y en oscuro.
  final AppTone tone;

  /// Filtro al que pertenece; nulo si el tipo aún no está clasificado.
  final NotificationCategory? category;
}

/// Descripción para un tipo desconocido del backend.
///
/// Se muestra, pero no se filtra: un aviso nuevo nunca debe desaparecer de la
/// bandeja «Todas» ni inventarse una categoría.
const NotificationTypeDescriptor _unknown = NotificationTypeDescriptor(
  label: 'Notificación',
  icon: Icons.notifications_active_outlined,
  tone: AppTone.neutral,
);

/// Tipos que la app conoce, con su ícono, etiqueta, tono y filtro.
const Map<String, NotificationTypeDescriptor> _registry = {
  // Feria y proyectos
  'FAIR_OPENED': NotificationTypeDescriptor(
    label: 'Feria abierta',
    icon: Icons.event_available_rounded,
    tone: AppTone.primary,
    category: NotificationCategory.fair,
  ),
  'FAIR_CLOSED': NotificationTypeDescriptor(
    label: 'Feria cerrada',
    icon: Icons.event_busy_rounded,
    tone: AppTone.neutral,
    category: NotificationCategory.fair,
  ),
  'EVALUATION_OPENED': NotificationTypeDescriptor(
    label: 'Evaluación abierta',
    icon: Icons.assignment_turned_in_rounded,
    tone: AppTone.primary,
    category: NotificationCategory.fair,
  ),
  'RUBRIC_ASSIGNED': NotificationTypeDescriptor(
    label: 'Rúbrica asignada',
    icon: Icons.fact_check_outlined,
    tone: AppTone.info,
    category: NotificationCategory.fair,
  ),
  'RATING_RECEIVED': NotificationTypeDescriptor(
    label: 'Calificación recibida',
    icon: Icons.workspace_premium_outlined,
    tone: AppTone.success,
    category: NotificationCategory.fair,
  ),
  'PROJECT_LIKED': NotificationTypeDescriptor(
    label: 'Me gusta',
    icon: Icons.favorite_rounded,
    tone: AppTone.primary,
    category: NotificationCategory.fair,
  ),
  'PROJECT_COMMENTED': NotificationTypeDescriptor(
    label: 'Comentario',
    icon: Icons.chat_bubble_outline_rounded,
    tone: AppTone.info,
    category: NotificationCategory.fair,
  ),
  'PROJECT_LIKE_MILESTONE': NotificationTypeDescriptor(
    label: 'Proyecto destacado',
    icon: Icons.trending_up_rounded,
    tone: AppTone.success,
    category: NotificationCategory.fair,
  ),
  'ASSISTED_PROJECT_PREPARED': NotificationTypeDescriptor(
    label: 'Proyecto asistido',
    icon: Icons.volunteer_activism_outlined,
    tone: AppTone.info,
    category: NotificationCategory.fair,
  ),
  'ASSISTED_PROJECT_CONFIRMED': NotificationTypeDescriptor(
    label: 'Proyecto confirmado',
    icon: Icons.verified_rounded,
    tone: AppTone.success,
    category: NotificationCategory.fair,
  ),
  'JURY_CONFLICT_DECLARED': NotificationTypeDescriptor(
    label: 'Conflicto de interés',
    icon: Icons.warning_amber_rounded,
    tone: AppTone.danger,
    category: NotificationCategory.fair,
  ),
  'JURY_RECUSAL_REVOKED': NotificationTypeDescriptor(
    label: 'Recusación revocada',
    icon: Icons.undo_rounded,
    tone: AppTone.warning,
    category: NotificationCategory.fair,
  ),

  // Avisos oficiales
  'SYSTEM_ALERT': NotificationTypeDescriptor(
    label: 'Aviso institucional',
    icon: Icons.campaign_rounded,
    tone: AppTone.warning,
    category: NotificationCategory.official,
  ),
  'DEADLINE_REMINDER': NotificationTypeDescriptor(
    label: 'Recordatorio de fecha',
    icon: Icons.schedule_rounded,
    tone: AppTone.warning,
    category: NotificationCategory.official,
  ),
  'ACTA_DELIVERY': NotificationTypeDescriptor(
    label: 'Acta entregada',
    icon: Icons.description_outlined,
    tone: AppTone.info,
    category: NotificationCategory.official,
  ),
  'WELCOME': NotificationTypeDescriptor(
    label: 'Bienvenida',
    icon: Icons.waving_hand_rounded,
    tone: AppTone.success,
    category: NotificationCategory.official,
  ),
  'ACCOUNT_VERIFIED': NotificationTypeDescriptor(
    label: 'Cuenta verificada',
    icon: Icons.verified_user_rounded,
    tone: AppTone.success,
    category: NotificationCategory.official,
  ),
  'EMAIL_ALERT': NotificationTypeDescriptor(
    label: 'Al correo',
    icon: Icons.mail_rounded,
    tone: AppTone.info,
    category: NotificationCategory.official,
  ),
  'JURY_ASSIGNED': NotificationTypeDescriptor(
    label: 'Jurado asignado',
    icon: Icons.gavel_rounded,
    tone: AppTone.primary,
    category: NotificationCategory.official,
  ),
  'PROJECT_ASSIGNED': NotificationTypeDescriptor(
    label: 'Proyecto asignado',
    icon: Icons.folder_shared_rounded,
    tone: AppTone.info,
    category: NotificationCategory.official,
  ),
  'CALIFICATION_ACTIVE': NotificationTypeDescriptor(
    label: 'Calificación activa',
    icon: Icons.how_to_vote_rounded,
    tone: AppTone.primary,
    category: NotificationCategory.official,
  ),
};

/// Descriptor de un tipo de aviso; nunca lanza: los desconocidos usan [_unknown].
NotificationTypeDescriptor notificationType(String type) =>
    _registry[type] ?? _unknown;

/// Si el app ya conoce el tipo (o sea, si aparece en los filtros).
bool isKnownNotificationType(String type) => _registry.containsKey(type);