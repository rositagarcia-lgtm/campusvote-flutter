import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/endpoints.dart';
import '../../core/di/core_providers.dart';
import 'notification_item.dart';
import 'notifications_state.dart';

class _NotificationRequestFailure implements Exception {
  const _NotificationRequestFailure(this.statusCode);
  final int? statusCode;
}

/// El servidor manda la lista en `data` y el total en `meta.pagination`.
/// También se acepta el objeto `{ notifications, pagination }` por si cambia.
class _NotificationPage {
  const _NotificationPage(this.items, this.total);

  final List<NotificationItem> items;
  final int? total;
}

_NotificationPage _notificationPage(Object? body) {
  if (body is! Map || body['success'] != true) {
    throw const FormatException('Respuesta de notificaciones inválida');
  }
  final data = body['data'];
  final List<dynamic> raw;
  final Object? pagination;
  if (data is List) {
    raw = data;
    final meta = body['meta'];
    pagination = meta is Map ? meta['pagination'] : null;
  } else if (data is Map && data['notifications'] is List) {
    raw = data['notifications'] as List;
    pagination = data['pagination'];
  } else {
    throw const FormatException('Respuesta de notificaciones inválida');
  }
  final total = pagination is Map && pagination['total'] is num
      ? (pagination['total'] as num).toInt()
      : null;
  return _NotificationPage(
    raw
        .whereType<Map>()
        .map(
          (item) => NotificationItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false),
    total,
  );
}

final notificationsControllerProvider = StateNotifierProvider.autoDispose<
    NotificationsController, NotificationsState>(
  (ref) => NotificationsController(ref),
);

class NotificationsController extends StateNotifier<NotificationsState> {
  NotificationsController(this._ref) : super(const NotificationsState()) {
    load();
  }

  final Ref _ref;

  bool get hasMore => state.items.length < state.total;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final api = _ref.read(apiClientProvider);
      final responses = await Future.wait([
        api.get(NotificationEndpoints.list, query: {'page': 1, 'limit': 20}),
        api.get(NotificationEndpoints.unreadCount),
      ]);
      final listBody = responses[0].data;
      final countBody = responses[1].data;
      for (final response in responses) {
        if ((response.statusCode ?? 500) >= 400) {
          throw _NotificationRequestFailure(response.statusCode);
        }
      }
      final page = _notificationPage(listBody);
      if (countBody is! Map || countBody['success'] != true) {
        throw const FormatException('Respuesta de notificaciones inválida');
      }
      final countData = countBody['data'];
      final count = countData is Map ? countData['unread_count'] : null;
      state = state.copyWith(
        loading: false,
        page: 1,
        total: page.total ?? page.items.length,
        items: page.items,
        unreadCount: count is num ? count.toInt() : 0,
      );
    } catch (error) {
      state = state.copyWith(
        loading: false,
        error: _errorMessage(error),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.loading || !hasMore) return;
    final nextPage = state.page + 1;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final response = await _ref.read(apiClientProvider).get(
        NotificationEndpoints.list,
        query: {'page': nextPage, 'limit': 20},
      );
      if ((response.statusCode ?? 500) >= 400) {
        throw _NotificationRequestFailure(response.statusCode);
      }
      final page = _notificationPage(response.data);
      final knownIds = state.items.map((item) => item.id).toSet();
      state = state.copyWith(
        loading: false,
        page: nextPage,
        total: page.total ?? state.total,
        items: [
          ...state.items,
          for (final item in page.items)
            if (!knownIds.contains(item.id)) item,
        ],
      );
    } catch (error) {
      state = state.copyWith(
        loading: false,
        error: _errorMessage(error),
      );
    }
  }

  Future<bool> markRead(String id) async {
    state = state.copyWith(updatingId: id, clearError: true);
    try {
      final response = await _ref.read(apiClientProvider).patch(
        NotificationEndpoints.markRead(id),
        body: {'is_read': true},
      );
      final body = response.data;
      if ((response.statusCode ?? 500) >= 400) {
        throw _NotificationRequestFailure(response.statusCode);
      }
      if (body is! Map || body['success'] != true) {
        throw const FormatException('No se pudo actualizar la notificación');
      }
      state = state.copyWith(
        items: [
          for (final item in state.items)
            if (item.id == id) item.copyWith(isRead: true) else item,
        ],
        unreadCount: state.items.any((item) => item.id == id && !item.isRead)
            ? (state.unreadCount - 1).clamp(0, state.unreadCount)
            : state.unreadCount,
        clearUpdating: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        clearUpdating: true,
        error: _errorMessage(error, action: 'No se pudo marcar como leída.'),
      );
      return false;
    }
  }

  Future<bool> markAllRead() async {
    state = state.copyWith(updatingId: 'all', clearError: true);
    try {
      final response = await _ref
          .read(apiClientProvider)
          .patch(NotificationEndpoints.markAllRead);
      final body = response.data;
      if ((response.statusCode ?? 500) >= 400) {
        throw _NotificationRequestFailure(response.statusCode);
      }
      if (body is! Map || body['success'] != true) {
        throw const FormatException('No se pudieron actualizar');
      }
      state = state.copyWith(
        items: [for (final item in state.items) item.copyWith(isRead: true)],
        unreadCount: 0,
        clearUpdating: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        clearUpdating: true,
        error: _errorMessage(error,
            action: 'No se pudieron marcar todas como leídas.'),
      );
      return false;
    }
  }

  String _errorMessage(Object error, {String? action}) {
    if (error is _NotificationRequestFailure) {
      final statusCode = error.statusCode;
      if (statusCode == null) {
        return action ?? 'No se pudo completar la solicitud.';
      }
      return switch (statusCode) {
        401 => 'Tu sesión expiró. Inicia sesión de nuevo.',
        403 => 'Tu cuenta no tiene permiso para consultar estos avisos.',
        >= 500 => 'El servidor no está disponible. Inténtalo más tarde.',
        _ => action ?? 'No se pudo cargar la bandeja de notificaciones.',
      };
    }
    return action == null
        ? 'No se pudieron cargar tus notificaciones. Revisa tu conexión e inténtalo de nuevo.'
        : '$action Inténtalo de nuevo.';
  }
}
