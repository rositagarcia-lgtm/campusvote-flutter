import 'package:campusvote_flutter/app/splash_widgets.dart';
import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selección de acceso mantiene acciones y texto ampliado',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var selected = '';

    for (final width in [320.0, 390.0, 430.0, 768.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 850);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 850),
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: Column(
                  children: [
                    const WelcomeHeader(),
                    const SizedBox(height: AppSpacing.xl),
                    const SectionHeading(
                      overline: 'BIENVENIDO',
                      title: 'Elige cómo participar',
                      subtitle: 'Cada perfil tiene un acceso propio.',
                    ),
                    const SizedBox(height: AppSpacing.l),
                    AccessCard(
                      icon: Icons.school_outlined,
                      actionIcon: Icons.mail_outline_rounded,
                      accent: Colors.teal,
                      title: 'Estudiante',
                      subtitle:
                          'Evalúa a tus docentes con un código enviado a tu correo institucional.',
                      action: 'Continuar con mi correo',
                      onTap: () => selected = 'student',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'ancho $width');
      expect(find.text('Elige cómo participar'), findsOneWidget);
      await tester.tap(find.text('Continuar con mi correo'));
      expect(selected, 'student');
    }
  });
}
