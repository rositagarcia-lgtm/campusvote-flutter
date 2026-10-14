import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/jury/presentation/projects/widgets/declaration_gate.dart';
import 'package:campusvote_flutter/features/jury/presentation/projects/widgets/fair_actions_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _app(Widget child) {
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => Scaffold(body: child)),
    GoRoute(
      path: '/jury/fair/:fairId/declaration',
      builder: (_, __) => const Scaffold(body: Text('DECLARACIÓN')),
    ),
  ]);
  return MaterialApp.router(theme: AppTheme.light(), routerConfig: router);
}

void main() {
  testWidgets('sin declaración: explica el paso y lleva a firmarla',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(const DeclarationGate(fairId: 'f1')));
    await tester.pumpAndSettle();

    expect(find.text('Firma tu declaración de imparcialidad'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Firmar declaración'));
    await tester.pumpAndSettle();
    expect(find.text('DECLARACIÓN'), findsOneWidget);
  });

  testWidgets('la votación queda bloqueada hasta firmar', (tester) async {
    await tester
        .pumpWidget(_app(const FairActionsBar(fairId: 'f1', locked: true)));
    await tester.pumpAndSettle();

    expect(find.text('Votación (firma primero)'), findsOneWidget);
    await tester.tap(find.text('Votación (firma primero)'));
    await tester.pumpAndSettle();
    // No navega: el botón está deshabilitado.
    expect(find.text('Votación (firma primero)'), findsOneWidget);
  });
}
