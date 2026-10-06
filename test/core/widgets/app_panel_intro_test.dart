import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/core/widgets/app_panel_intro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('encabezado institucional se adapta a móvil y tablet',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> pumpAt(double width, double textScale) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 900),
              textScaler: TextScaler.linear(textScale),
            ),
            child: const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: AppPanelIntro(
                  organizationName:
                      'Instituci\u00f3n P\u00fablica de Innovaci\u00f3n',
                  contextLabel: 'Panel oficial del jurado',
                  title: 'Ferias asignadas',
                  subtitle:
                      'Revisa tu participaci\u00f3n y accede a las ferias habilitadas para ti.',
                  primaryValue: 1,
                  primaryLabel: 'abiertas',
                  secondaryValue: 2,
                  secondaryLabel: 'asignadas',
                  tertiaryValue: 1,
                  tertiaryLabel: 'cerradas',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: 'ancho $width, escala $textScale');
      expect(find.text('Ferias asignadas'), findsOneWidget);
      expect(find.text('Panel oficial del jurado'), findsOneWidget);
      expect(find.text('cerrada'), findsOneWidget);
      expect(find.text('Instituci\u00f3n P\u00fablica de Innovaci\u00f3n'),
          findsOneWidget);
    }

    for (final width in [320.0, 390.0, 430.0, 768.0]) {
      await pumpAt(width, 1.0);
    }
    await pumpAt(320, 1.6);
  });
}
