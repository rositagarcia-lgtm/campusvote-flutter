// notifications_state.dart

import 'notification_item.dart';

/// Estado de la bandeja de avisos.
///
/// Es inmutable y se copia campo a campo: [copyWith] distingue «dejar como
/// está» de «limpiar», que es lo que necesita el controlador para no dejar un
/// `updatingId` o un `error` pegado tras una operación correcta.
class NotificationsState {
  const NotificationsState({
    this.items = const [],
    this.unreadCount = 0,
    this.total = 0,
    this.page = 1,
    this.loading = true,
    this.updatingId,
    this.error,
  });

  /// Avisos cargados hasta ahora, en orden del servidor.
  final List<NotificationItem> items;

  final int unreadCount;

  /// Total informado por la paginación; puede superar [items.length].
  final int total;

  final int page;

  final bool loading;

  /// Id del aviso en curso de marcar como leído, o `all` para el marcado
  /// masivo; nulo si no hay ninguna operación en vuelo.
  final String? updatingId;

  final String? error;

  NotificationsState copyWith({
    List<NotificationItem>? items,
    int? unreadCount,
    int? total,
    int? page,
    bool? loading,
    String? updatingId,
    String? error,
    bool clearError = false,
    bool clearUpdating = false,
  }) =>
      NotificationsState(
        items: items ?? this.items,
        unreadCount: unreadCount ?? this.unreadCount,
        total: total ?? this.total,
        page: page ?? this.page,
        loading: loading ?? this.loading,
        updatingId: clearUpdating ? null : (updatingId ?? this.updatingId),
        error: clearError ? null : (error ?? this.error),
      );
}