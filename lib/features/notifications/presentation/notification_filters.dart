// notification_filters.dart

import '../notification_item.dart';
import 'notification_type.dart';

/// Filtros de la bandeja de avisos.
enum NotificationFilter {
  all(null, 'Todas'),
  official(NotificationCategory.official, 'Oficiales'),
  fair(NotificationCategory.fair, 'Feria y proyectos');

  const NotificationFilter(this.category, this.label);

  /// Familia que agrupa este filtro; `all` no agrupa ninguna.
  final NotificationCategory? category;

  /// Nombre del filtro, ya corto para la píldora.
  final String label;

  bool get isAll => category == null;
}

/// Si un aviso entra en el filtro.
///
/// La pertenencia sale de la misma tabla que el ícono y la etiqueta, así que no
/// puede desincronizarse. Un tipo desconocido solo aparece en «Todas».
bool matchesNotificationFilter(NotificationItem item, NotificationFilter filter) =>
    filter.isAll || notificationType(item.type).category == filter.category;

/// Cuántos avisos hay en cada filtro.
///
/// Se cuenta con el mismo predicado que filtra la lista: si cambia la
/// clasificación, cambian los dos a la vez.
Map<NotificationFilter, int> notificationFilterCounts(
    List<NotificationItem> items) {
  return {
    for (final filter in NotificationFilter.values)
      filter: items.where((item) => matchesNotificationFilter(item, filter)).length,
  };
}