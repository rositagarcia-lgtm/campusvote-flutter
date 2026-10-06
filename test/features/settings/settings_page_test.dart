import 'package:campusvote_flutter/core/settings/app_preferences.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'settings_pump.dart';

export 'settings_pump.dart';

void main() {
  testWidgets('avisa que el tema sigue al sistema hasta que el usuario elige',
      (tester) async {
    await pumpSettings(tester);
    expect(find.text('Sigue el tema de tu dispositivo'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Sigue el tema de tu dispositivo'), findsNothing);
    expect(
        find.text('Usa un tema oscuro en toda la aplicación'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cada muestra "Aa" mide su propio tamaño, sin duplicarse',
      (tester) async {
    await pumpSettings(tester);
    // Las tres muestras son estáticas: cada una enseña el tamaño que ofrece,
    // no el elegido. Su orden es Pequeño, Normal, Grande.
    final small = tester.getSize(find.text('Aa').at(0)).width;
    final normal = tester.getSize(find.text('Aa').at(1)).width;
    final large = tester.getSize(find.text('Aa').at(2)).width;

    // Si una muestra heredara el escalado ambiente y además multiplicara el
    // factor, crecería al cuadrado respecto de la app.
    expect(large, greaterThan(normal));
    expect(normal, greaterThan(small));
    expect(large / normal, closeTo(1.12, 0.05));
    expect(normal / small, closeTo(1.12, 0.05));

    // Elegir «Grande» cambia el escalado de toda la app, pero la muestra no se
    // vuelve a multiplicar: mide lo mismo que antes.
    await tester.tap(find.text('Grande'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.text('Aa').at(2)).width, closeTo(large, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cada opción de tamaño es un botón con etiqueta y estado',
      (tester) async {
    await pumpSettings(tester);

    for (final label in ['Pequeño', 'Normal', 'Grande']) {
      expect(find.text(label), findsOneWidget);
      expect(semanticsButtonFor(tester, label).properties.label, label);
      expect(semanticsButtonFor(tester, label).properties.selected,
          label == 'Normal');
    }

    await tester.tap(find.text('Grande'));
    await tester.pumpAndSettle();
    expect(semanticsButtonFor(tester, 'Grande').properties.selected, isTrue);
    expect(semanticsButtonFor(tester, 'Normal').properties.selected, isFalse);
  });

  testWidgets('idioma: las etiquetas cambian al instante y en ambos sentidos',
      (tester) async {
    await pumpSettings(tester);
    expect(find.text('Español'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('LANGUAGE'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);

    await tester.tap(find.text('Spanish'));
    await tester.pumpAndSettle();
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cabe en 320 px con texto grande y en claro/oscuro',
      (tester) async {
    for (final dark in [false, true]) {
      for (final size in AppTextSize.values) {
        await pumpSettings(
          tester,
          size: const Size(320, 640),
          dark: dark,
          storedTextSize: size,
        );
        expect(tester.takeException(), isNull, reason: 'dark=$dark, size=$size');
        expect(find.text('Configuración'), findsOneWidget);
      }
    }
  });

  testWidgets('el idioma guardado antes de abrir la app se respeta',
      (tester) async {
    await pumpSettings(tester, storedLanguage: 'en');
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
  });

  test('la copia de Configuración responde en ambos idiomas', () {
    const es = SettingsCopy(AppLanguage.spanish);
    const en = SettingsCopy(AppLanguage.english);
    expect(es.title, 'Configuración');
    expect(en.title, 'Settings');
    expect(es.back, 'Volver');
    expect(en.back, 'Back');
    expect(es.darkModeSystemHint, 'Sigue el tema de tu dispositivo');
    expect(en.darkModeSystemHint, 'Following your device theme');
    expect(es.large, 'Grande');
    expect(en.large, 'Large');
    expect(es.preferencesTitle, 'Preferencias del sistema');
    expect(en.preferencesTitle, 'System preferences');
    expect(es.logoLabel('Tecsup'), 'Logo de Tecsup');
    expect(en.logoLabel('Tecsup'), 'Logo of Tecsup');
  });
}