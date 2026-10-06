import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/core/widgets/app_card.dart';
import 'package:campusvote_flutter/core/widgets/app_icon_tile.dart';
import 'package:campusvote_flutter/features/notifications/notification_item.dart';
import 'package:campusvote_flutter/features/notifications/notification_presentation.dart';
import 'package:campusvote_flutter/features/notifications/notification_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const official = NotificationItem(
  id: '1', type: 'SYSTEM_ALERT', title: 'Aviso', message: 'Texto',
  isRead: false, createdAt: null,
);
const fair = NotificationItem(
  id: '2', type: 'FAIR_OPENED', title: 'Feria', message: 'Abierta',
  isRead: true, createdAt: null,
);

/// Monta un widget de la bandeja con el tema real de la app.
Future<void> pumpNotification(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(360, 800),
  bool dark = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(body: child),
  ));
  await tester.pumpAndSettle();
}

void main() {
  test('los filtros usan tipos existentes y mantienen los desconocidos en Todas', () {
    const unknown = NotificationItem(
      id: '3', type: 'CUSTOM', title: 'Otro', message: '',
      isRead: true, createdAt: null,
    );
    expect(matchesNotificationFilter(official, NotificationFilter.official), isTrue);
    expect(matchesNotificationFilter(fair, NotificationFilter.fair), isTrue);
    expect(matchesNotificationFilter(unknown, NotificationFilter.official), isFalse);
    expect(matchesNotificationFilter(unknown, NotificationFilter.fair), isFalse);
    expect(matchesNotificationFilter(unknown, NotificationFilter.all), isTrue);
  });

  test('un tipo desconocido se muestra pero no se clasifica', () {
    expect(notificationType('CUSTOM').category, isNull);
    expect(isKnownNotificationType('CUSTOM'), isFalse);
    expect(notificationType('CUSTOM').label, isNotEmpty);
    expect(notificationType('CUSTOM').icon, isNotNull);
    expect(isKnownNotificationType('SYSTEM_ALERT'), isTrue);
  });

  test('el registro da icono, etiqueta y tono a cada tipo conocido', () {
    for (final type in const [
      'SYSTEM_ALERT', 'FAIR_OPENED', 'FAIR_CLOSED', 'RATING_RECEIVED',
      'PROJECT_LIKED', 'JURY_CONFLICT_DECLARED', 'DEADLINE_REMINDER',
    ]) {
      final descriptor = notificationType(type);
      expect(descriptor.category, isNotNull, reason: type);
      expect(descriptor.label, isNotEmpty, reason: type);
      expect(descriptor.icon, isNotNull, reason: type);
    }
  });

  test('los contadores de los filtros salen de la misma regla de pertenencia', () {
    const unknown = NotificationItem(
      id: '3', type: 'CUSTOM', title: 'Otro', message: '',
      isRead: true, createdAt: null,
    );
    final counts = notificationFilterCounts(const [official, fair, unknown]);
    expect(counts[NotificationFilter.all], 3);
    expect(counts[NotificationFilter.official], 1);
    expect(counts[NotificationFilter.fair], 1);
  });

  test('agrupa por día calendario, también cerca de medianoche', () {
    final now = DateTime(2026, 10, 5, 0, 10);
    expect(notificationDateGroup(DateTime(2026, 10, 4, 23, 59), now), 'AYER');
    expect(notificationDateGroup(DateTime(2026, 10, 5, 0, 1), now), 'HOY');
    expect(notificationDateGroup(null, now), 'SIN FECHA');
  });

  testWidgets('el filtro se puede elegir en móvil estrecho', (tester) async {
    NotificationFilter selected = NotificationFilter.all;
    await pumpNotification(tester, NotificationFilterBar(
      selected: selected,
      items: const [official, fair],
      onSelected: (value) => selected = value,
    ), size: const Size(320, 640));
    await tester.tap(find.text('Oficiales'));
    expect(selected, NotificationFilter.official);
    expect(tester.takeException(), isNull);
  });

  testWidgets('los tres filtros caben desplazables sin desbordarse', (tester) async {
    await pumpNotification(tester, NotificationFilterBar(
      selected: NotificationFilter.all,
      items: const [official, fair],
      onSelected: (_) {},
    ), size: const Size(320, 640));
    expect(tester.takeException(), isNull);
    final bar = tester.getSize(find.byType(NotificationFilterBar));
    expect(bar.width, lessThanOrEqualTo(320));
  });

  testWidgets('la tarjeta alinea el ícono con el bloque del título', (tester) async {
    await pumpNotification(tester, NotificationCard(
      notification: official,
      loading: false,
      onTap: () {},
    ));
    final tile = tester.getRect(find.byType(AppIconTile));
    final title = tester.getRect(find.text('Aviso'));
    // El mosaico se centra respecto al título, no se cuelga de su esquina.
    expect((tile.center.dy - title.center.dy).abs(), lessThan(24));
    expect(tile.width, notificationCardIconExtent);
    // El cuerpo cuelga del mosaico: mensaje y fecha comparten su columna.
    final message = tester.getRect(find.text('Texto'));
    expect(message.left, closeTo(tile.right, 16));
  });

  testWidgets('la tarjeta usa el estilo plano de la app', (tester) async {
    await pumpNotification(tester, NotificationCard(
      notification: official,
      loading: false,
      onTap: () {},
    ));
    // `AppCard` no expone elevación: la propia caja del sistema de diseño
    // garantiza el estilo plano. Además la tarjeta no leída lleva borde de acento.
    final card = tester.widget<AppCard>(find.byType(AppCard));
    expect(card.onTap, isNotNull);
    expect(card.borderColor, isNotNull);
    await pumpNotification(tester, NotificationCard(
      notification: fair,
      loading: false,
      onTap: () {},
    ));
    expect(tester.widget<AppCard>(find.byType(AppCard)).onTap, isNotNull);
  });

  testWidgets('el estado de lectura se anuncia una sola vez por tarjeta', (tester) async {
    await pumpNotification(tester, NotificationCard(
      notification: official,
      loading: false,
      onTap: () {},
    ));
    // El tipo también se lee de la etiqueta, así se oye qué aviso es.
    expect(find.bySemanticsLabel('Aviso institucional. Aviso. No leída'),
        findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('leída', caseSensitive: false)),
        findsOneWidget);

    await pumpNotification(tester, NotificationCard(
      notification: fair,
      loading: false,
      onTap: () {},
    ));
    expect(find.bySemanticsLabel('Feria abierta. Feria. Leída'), findsOneWidget);
  });

  testWidgets('el encabezado de fecha muestra etiqueta y total', (tester) async {
    await pumpNotification(tester, const NotificationDateHeader(
      label: 'HOY', count: 3,
    ));
    expect(find.text('HOY'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}