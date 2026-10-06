import 'package:campusvote_flutter/core/branding/organization_branding.dart';
import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/core/widgets/organization_panel_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('usa la identidad de la organización en los paneles',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    const branding = OrganizationBranding(
      id: 'tecsup',
      name: 'Tecsup',
      primaryColor: Color(0xFF009ECC),
      secondaryColor: Color(0xFF007A9B),
    );
    for (final width in [320.0, 390.0, 430.0, 768.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(branding: branding),
        home: const Scaffold(
          appBar: OrganizationPanelAppBar(
            branding: branding,
            section: 'Mi cuenta',
            actions: [IconButton(onPressed: null, icon: Icon(Icons.settings))],
          ),
        ),
      ));
      expect(tester.takeException(), isNull, reason: 'ancho $width');
      expect(find.text('Tecsup'), findsOneWidget);
      expect(find.text('Mi cuenta'), findsOneWidget);
      expect(find.text('CampusVote'), findsNothing);
    }
  });
}
