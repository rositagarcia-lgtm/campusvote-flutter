import 'package:campusvote_flutter/core/branding/organization_branding.dart';
import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/auth/presentation/widgets/account_widgets.dart';
import 'package:campusvote_flutter/features/auth/presentation/widgets/security/account_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('organización y correo largo se adaptan sin desbordarse',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    const branding = OrganizationBranding(
      id: 'org-1',
      name: 'Instituto de Tecnología Aplicada',
      primaryColor: Color(0xFF006A63),
      secondaryColor: Color(0xFF946200),
    );
    for (final width in [320.0, 390.0, 430.0, 768.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(branding: branding),
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(children: [
              AccountSection(
                overline: 'Institución',
                child: AccountOrganizationRow(branding: branding),
              ),
              // El carnet es ahora el único lugar con nombre y correo.
              AccountIdentityHeader(
                accent: Color(0xFF006A63),
                avatarUrl: null,
                displayName: 'Nombre Apellido Extenso',
                email: 'nombre.apellido.muy.largo@institucion.edu.pe',
                roleLabel: 'Jurado',
                uploading: false,
                onPickPhoto: _noop,
              ),
            ]),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'ancho $width');
      expect(find.text(branding.name), findsOneWidget);
      expect(find.text('nombre.apellido.muy.largo@institucion.edu.pe'),
          findsOneWidget);
    }
  });
}

void _noop() {}
