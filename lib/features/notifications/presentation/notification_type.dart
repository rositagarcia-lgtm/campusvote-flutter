// notification_type.dart

import 'package:flutter/material.dart';

import '../../../core/theme/app_icons.dart';
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
  icon: PhosphorIconsRegular.bellRinging,
  tone: AppTone.neutral,
);

/// Tipos que la app conoce, con su ícono, etiqueta, tono y filtro.
const Map<String, NotificationTypeDescriptor> _registry = {
  // Feria y proyectos
  'FAIR_OPENED': NotificationTypeDescriptor(
    label: 'Feria abierta',
    icon: PhosphorIconsFill.calendarCheck,
    tone: AppTone.primary,
    category: NotificationCategory.fair,
  ),
  'FAIR_CLOSED': NotificationTypeDescriptor(
    label: 'Feria cerrada',
    icon: PhosphorIconsRegular.calendarX,
    tone: AppTone.neutral,
    category: NotificationCategory.fair,
  ),
  'EVALUATION_OPENED': NotificationTypeDescriptor(
    label: 'Evaluación abierta',
    icon: PhosphorIconsFill.clipboardText,
    tone: AppTone.primary,
    category: NotificationCategory.fair,
  ),
  'RUBRIC_ASSIGNED': NotificationTypeDescriptor(
    label: 'Rúbrica asignada',
    icon: PhosphorIconsRegular.listChecks,
    tone: AppTone.info,
    category: NotificationCategory.fair,
  ),
  'RATING_RECEIVED': NotificationTypeDescriptor(
    label: 'Calificación recibida',
    icon: PhosphorIconsRegular.medal,
    tone: AppTone.success,
    category: NotificationCategory.fair,
  ),
  'PROJECT_LIKED': NotificationTypeDescriptor(
    label: 'Me gusta',
    icon: PhosphorIconsFill.heart,
    tone: AppTone.primary,
    category: NotificationCategory.fair,
  ),
  'PROJECT_COMMENTED': NotificationTypeDescriptor(
    label: 'Comentario',
    icon: PhosphorIconsRegular.chatCircle,
    tone: AppTone.info,
    category: NotificationCategory.fair,
  ),
  'PROJECT_LIKE_MILESTONE': NotificationTypeDescriptor(
    label: 'Proyecto destacado',
    icon: PhosphorIconsRegular.trendUp,
    tone: AppTone.success,
    category: NotificationCategory.fair,
  ),
  'ASSISTED_PROJECT_PREPARED': NotificationTypeDescriptor(
    label: 'Proyecto asistido',
    icon: PhosphorIconsRegular.handHeart,
    tone: AppTone.info,
    category: NotificationCategory.fair,
  ),
  'ASSISTED_PROJECT_CONFIRMED': NotificationTypeDescriptor(
    label: 'Proyecto confirmado',
    icon: PhosphorIconsFill.sealCheck,
    tone: AppTone.success,
    category: NotificationCategory.fair,
  ),
  'JURY_CONFLICT_DECLARED': NotificationTypeDescriptor(
    label: 'Conflicto de interés',
    icon: PhosphorIconsRegular.warning,
    tone: AppTone.danger,
    category: NotificationCategory.fair,
  ),
  'JURY_RECUSAL_REVOKED': NotificationTypeDescriptor(
    label: 'Recusación revocada',
    icon: PhosphorIconsRegular.arrowCounterClockwise,
    tone: AppTone.warning,
    category: NotificationCategory.fair,
  ),

  // Avisos oficiales
  'SYSTEM_ALERT': NotificationTypeDescriptor(
    label: 'Aviso institucional',
    icon: PhosphorIconsRegular.megaphone,
    tone: AppTone.warning,
    category: NotificationCategory.official,
  ),
  'DEADLINE_REMINDER': NotificationTypeDescriptor(
    label: 'Recordatorio de fecha',
    icon: PhosphorIconsRegular.clock,
    tone: AppTone.warning,
    category: NotificationCategory.official,
  ),
  'ACTA_DELIVERY': NotificationTypeDescriptor(
    label: 'Acta entregada',
    icon: PhosphorIconsRegular.fileText,
    tone: AppTone.info,
    category: NotificationCategory.official,
  ),
  'WELCOME': NotificationTypeDescriptor(
    label: 'Bienvenida',
    icon: PhosphorIconsRegular.handWaving,
    tone: AppTone.success,
    category: NotificationCategory.official,
  ),
  'ACCOUNT_VERIFIED': NotificationTypeDescriptor(
    label: 'Cuenta verificada',
    icon: PhosphorIconsFill.shieldCheck,
    tone: AppTone.success,
    category: NotificationCategory.official,
  ),
  'EMAIL_ALERT': NotificationTypeDescriptor(
    label: 'Al correo',
    icon: PhosphorIconsFill.envelopeSimple,
    tone: AppTone.info,
    category: NotificationCategory.official,
  ),
  'JURY_ASSIGNED': NotificationTypeDescriptor(
    label: 'Jurado asignado',
    icon: PhosphorIconsFill.gavel,
    tone: AppTone.primary,
    category: NotificationCategory.official,
  ),
  'PROJECT_ASSIGNED': NotificationTypeDescriptor(
    label: 'Proyecto asignado',
    icon: PhosphorIconsRegular.folderUser,
    tone: AppTone.info,
    category: NotificationCategory.official,
  ),
  'CALIFICATION_ACTIVE': NotificationTypeDescriptor(
    label: 'Calificación activa',
    icon: PhosphorIconsFill.checkSquareOffset,
    tone: AppTone.primary,
    category: NotificationCategory.official,
  ),
};

/// Descriptor de un tipo de aviso; nunca lanza: los desconocidos usan [_unknown].
NotificationTypeDescriptor notificationType(String type) =>
    _registry[type] ?? _unknown;

/// Si el app ya conoce el tipo (o sea, si aparece en los filtros).
bool isKnownNotificationType(String type) => _registry.containsKey(type);