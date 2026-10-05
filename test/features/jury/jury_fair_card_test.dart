import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/presentation/widgets/jury_fair_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  const fairName =
      'Feria de Ciencia y Tecnología con un nombre largo para probar el ajuste';

  testWidgets('feria cerrada no muestra una acción y se adapta a cuatro anchos',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const fair = FairAssignmentModel(
      fairId: 'fair-closed',
      organizationId: 'org-1',
      name: fairName,
      description: 'Proyectos de innovación de la sede.',
      status: FairStatus.closed,
      siteName: 'Sede Norte con nombre institucional extendido',
    );

    for (final width in [320.0, 390.0, 430.0, 768.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(_app(fair));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'ancho $width');
      expect(find.text(fairName), findsOneWidget);
      expect(find.text('Cerrada'), findsOneWidget);
      expect(find.text('Abrir feria'), findsNothing);
      expect(
          find.text('La participación en esta feria terminó.'), findsOneWidget);
    }
  });

  testWidgets('feria abierta ofrece una sola acción que navega al detalle',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);

    const fair = FairAssignmentModel(
      fairId: 'fair-open',
      organizationId: 'org-1',
      name: fairName,
      description: 'Proyectos de innovación de la sede.',
      status: FairStatus.open,
      siteName: 'Sede Norte',
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: FairCard(fair: fair),
            ),
          ),
        ),
        GoRoute(
          path: '/jury/fair/:fairId',
          builder: (_, __) => const Scaffold(body: Text('Detalle de feria')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(
      theme: AppTheme.light(),
      routerConfig: router,
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Abrir feria'), findsOneWidget);
    await tester.tap(find.text('Abrir feria'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle de feria'), findsOneWidget);
  });
}

Widget _app(FairAssignmentModel fair) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FairCard(fair: fair),
        ),
      ),
    );
