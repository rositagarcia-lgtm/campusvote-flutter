import 'package:flutter_test/flutter_test.dart';
import 'package:campusvote_flutter/features/notifications/notification_item.dart';

void main() {
  test('parsea campos y metadata del contrato de notificaciones', () {
    final item = NotificationItem.fromJson({
      'id': 'notification-1',
      'type': 'FAIR_OPENED',
      'title': 'Feria abierta',
      'message': 'Ya puedes ingresar',
      'is_read': false,
      'created_at': '2026-10-04T12:30:00.000Z',
      'metadata': {'fair_id': 'fair-1'},
    });

    expect(item.id, 'notification-1');
    expect(item.isRead, isFalse);
    expect(item.metadata['fair_id'], 'fair-1');
    expect(item.createdAt, isNotNull);
  });

  test('tolera metadata ausente sin construir rutas con datos inventados', () {
    final item = NotificationItem.fromJson({
      'id': 'notification-2',
      'type': 'SYSTEM_ALERT',
      'title': 'Aviso',
      'message': 'Mensaje',
      'is_read': true,
    });

    expect(item.metadata, isEmpty);
    expect(item.createdAt, isNull);
  });
}
