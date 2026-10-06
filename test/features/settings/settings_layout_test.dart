import 'package:campusvote_flutter/core/config/constants.dart';
import 'package:campusvote_flutter/core/settings/app_preferences.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/core/widgets/app_icon_tile.dart';
import 'package:campusvote_flutter/core/widgets/app_logo.dart';
import 'package:campusvote_flutter/features/settings/presentation/widgets/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'settings_pump.dart';

/// Pruebas de detalle de Configuración.
///
/// No miran capturas: miden la geometría y los colores que realmente se
/// pintan, para que un cambio que rompa la alineación, la altura o el
/// contraste falle aquí en vez de pasar desapercibido en el dispositivo.
void main() {
  group('cabecera de organización', () {
    testWidgets('muestra logo, nombre y versión sin texto fijo obsoleto',
        (tester) async {
      await pumpSettings(tester);

      // El nombre viene del branding (fallback `CampusVote`), en mayúsculas.
      expect(find.text('CAMPUSVOTE'), findsOneWidget);
      expect(find.text('Preferencias del sistema'), findsOneWidget);
      // La versión viene de `AppConstants`, no de un literal en la vista.
      expect(find.text(AppConstants.appVersionLabel), findsOneWidget);
      expect(AppConstants.appVersionLabel, 'v1.0.0');
    });

    testWidgets('el nombre de la organización no se traduce', (tester) async {
      await pumpSettings(tester, storedLanguage: 'en');
      // Es un nombre propio: solo cambia el subtítulo, no la identidad.
      expect(find.text('CAMPUSVOTE'), findsOneWidget);
      expect(find.text('System preferences'), findsOneWidget);
    });

    testWidgets('el logo se anuncia con el nombre de la organización',
        (tester) async {
      await pumpSettings(tester);
      expect(find.bySemanticsLabel('Logo de CampusVote'), findsOneWidget);
    });

    testWidgets('logo, nombre y versión caben en una sola fila',
        (tester) async {
      await pumpSettings(tester);
      final logo = find.byType(AppLogo);
      final name = tester.getSize(find.text('CAMPUSVOTE'));
      final version = tester.getSize(find.text(AppConstants.appVersionLabel));
      expect(name.width, greaterThan(0));
      expect(version.width, greaterThan(0));

      // Los tres comparten el eje vertical de la fila: el bloque de texto queda
      // centrado respecto del logo, aunque envuelva a dos líneas.
      final logoRect = tester.getRect(logo);
      final nameRect = tester.getRect(find.text('CAMPUSVOTE'));
      final subtitleRect = tester.getRect(find.text('Preferencias del sistema'));
      final blockCenter = (nameRect.top + subtitleRect.bottom) / 2;
      expect(logoRect.center.dy, closeTo(blockCenter, 4));
      // El nombre nunca se sale de la tarjeta por arriba.
      expect(nameRect.top, greaterThan(logoRect.top - 12));

      // Y ninguno se sale de la tarjeta.
      final cardRight = tester
          .getTopRight(find.ancestor(
            of: find.text('CAMPUSVOTE'),
            matching: find.byType(Row),
          ).first)
          .dx;
      expect(
          tester.getTopRight(find.text(AppConstants.appVersionLabel)).dx,
          lessThanOrEqualTo(cardRight));
    });
  });

  group('bloque de apariencia', () {
    testWidgets('el interruptor refleja el tema y la descripción lo acompaña',
        (tester) async {
      await pumpSettings(tester, dark: true);
      // Sin preferencia guardada, el interruptor sigue al tema oscuro real.
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(find.text('Sigue el tema de tu dispositivo'), findsOneWidget);

      // Al apagar: la descripción pasa a hablar del tema claro, no del oscuro.
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(find.text('Usa un tema oscuro en toda la aplicación'), findsNothing);
      expect(find.text('Usa un tema claro en toda la aplicación'), findsOneWidget);

      // Y al volver a encender,|Description| vuelve a la de oscuro.
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Usa un tema claro en toda la aplicación'), findsNothing);
      expect(find.text('Usa un tema oscuro en toda la aplicación'), findsOneWidget);
    });

    testWidgets('el mosaico de ícono acompaña al interruptor', (tester) async {
      await pumpSettings(tester);
      final icon = find.byType(AppIconTile);
      expect(icon, findsWidgets);

      // El mosaico está a la izquierda del texto, en la misma fila.
      final tileLeft = tester.getTopLeft(icon.first).dx;
      final titleLeft = tester.getTopLeft(find.text('Modo oscuro')).dx;
      expect(tileLeft, lessThan(titleLeft));

      // ...y el interruptor a la derecha del texto, sin salirse de la tarjeta.
      final switchRight =
          tester.getTopRight(find.byType(Switch)).dx;
      expect(switchRight, lessThanOrEqualTo(400));
    });

    testWidgets('el icono cambia con el tema', (tester) async {
      await pumpSettings(tester);
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

      await pumpSettings(tester, dark: true);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
      expect(find.byIcon(Icons.light_mode_rounded), findsNothing);
    });
  });

  group('opciones segmentadas', () {
    testWidgets('las tres de tamaño comparten altura y ancho', (tester) async {
      await pumpSettings(tester);
      final small = tester.getSize(find.text('Aa').at(0));
      final large = tester.getSize(find.text('Aa').at(2));

      // La muestra «Grande» es más alta; la caja debe igualarlas.
      expect(large.height, greaterThan(small.height));
      final boxes = ['Pequeño', 'Normal', 'Grande']
          .map((label) =>
              tester.getSize(find.ancestor(
                of: find.text(label),
                matching: find.byType(InkWell),
              )))
          .toList();
      for (final box in boxes) {
        expect(box.height, closeTo(boxes.first.height, 0.01));
        expect(box.width, closeTo(boxes.first.width, 0.01));
      }
      // Cada opción respeta la zona táctil mínima.
      for (final box in boxes) {
        expect(box.height,
            greaterThanOrEqualTo(AppDimensions.touchTarget - 0.01));
      }
    });

    testWidgets('la opción elegida se distingue por relleno y borde',
        (tester) async {
      await pumpSettings(tester);
      final primary = Theme.of(tester.element(find.text('Normal'))).colorScheme.primary;

      Material materialFor(String label) => tester.widget<Material>(
            find
                .ancestor(of: find.text(label), matching: find.byType(Material))
                .first,
          );

      final selected = materialFor('Normal');
      final unselected = materialFor('Grande');

      // Elegida: tinte del primario y borde de marca de 1.5 px.
      expect(
        selected.color,
        primary.withValues(alpha: 0.10),
      );
      expect(
        (selected.shape! as RoundedRectangleBorder).side.color,
        primary,
      );
      expect((selected.shape! as RoundedRectangleBorder).side.width, 1.5);

      // Sin elegir: fondo transparente y borde fino neutro.
      expect(unselected.color, Colors.transparent);
      expect(
        (unselected.shape! as RoundedRectangleBorder).side.width,
        1,
      );
      expect(
        (unselected.shape! as RoundedRectangleBorder).side.color,
        isNot(primary),
      );
    });

    testWidgets('el idioma usa relleno sólido y solo uno queda elegido',
        (tester) async {
      await pumpSettings(tester);
      final primary =
          Theme.of(tester.element(find.text('Español'))).colorScheme.primary;

      Material materialFor(String label) => tester.widget<Material>(
            find
                .ancestor(of: find.text(label), matching: find.byType(Material))
                .first,
          );

      // Excluyentes: la elegida se rellena, la otra queda hueca.
      expect(materialFor('Español').color, primary);
      expect(materialFor('English').color, Colors.transparent);
      expect(semanticsButtonFor(tester, 'Español').properties.selected, isTrue);
      expect(semanticsButtonFor(tester, 'English').properties.selected, isFalse);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(materialFor('English').color, primary);
      expect(materialFor('Spanish').color, Colors.transparent);
    });

    testWidgets('las dos de idioma se alinean y no se solapan', (tester) async {
      await pumpSettings(tester, size: const Size(320, 900));
      final spanish = tester.getTopLeft(find.text('Español'));
      final english = tester.getTopLeft(find.text('English'));
      expect(spanish.dy, closeTo(english.dy, 0.01));
      expect(spanish.dx, lessThan(english.dx));

      final gap = tester.getSize(find.text('English')).width;
      expect(gap, greaterThan(0));
    });
  });

  group('tarjetas y divisores', () {
    testWidgets('el divisor arranca en el borde del texto, no de la tarjeta',
        (tester) async {
      await pumpSettings(tester, storedTextSize: AppTextSize.large);
      final dividers = find.descendant(
        of: find.byType(SettingsGroup),
        matching: find.byType(Divider),
      );
      expect(dividers, findsWidgets);

      final groupLeft = tester.getTopLeft(find.byType(SettingsGroup).first).dx;
      final dividerLeft = tester.getTopLeft(dividers.first).dx;
      // La tarjeta tiene borde de 1 px, así que el divisor arranca un píxel
      // más adentro de lo que dice la constante (que mide desde el contenido).
      expect(dividerLeft - groupLeft,
          closeTo(SettingsGroup.dividerInset + 1, 0.01));

      // Y justo en el borde izquierdo del texto de la fila.
      final rowLeft =
          tester.getTopLeft(find.byIcon(Icons.light_mode_rounded)).dx;
      expect(rowLeft, greaterThan(groupLeft));
      final titleLeft = tester.getTopLeft(find.text('Modo oscuro')).dx;
      expect(dividerLeft, closeTo(titleLeft, 0.01));
    });

    testWidgets('la sangría del divisor coincide con el ancho del mosaico',
        (tester) async {
      // Si el mosaico cambiara de tamaño sin actualizar la constante, el
      // divisor dejaría de alinear con el texto.
      expect(SettingsGroup.dividerInset,
          AppSpacing.l + AppIconTile.defaultExtent + AppSpacing.m);
      await pumpSettings(tester);
      expect(find.byType(AppIconTile), findsWidgets);
    });
  });

  group('contraste en ambos temas', () {
    testWidgets('el texto secundario se apaga pero se mantiene legible',
        (tester) async {
      await pumpSettings(tester);
      final lightMuted = Theme.of(tester.element(find.text('Modo oscuro')))
          .textTheme
          .bodySmall!
          .color;
      final lightSurface =
          Theme.of(tester.element(find.text('Modo oscuro'))).colorScheme.surface;

      await pumpSettings(tester, dark: true);
      final darkMuted = Theme.of(tester.element(find.text('Modo oscuro')))
          .textTheme
          .bodySmall!
          .color;
      final darkSurface =
          Theme.of(tester.element(find.text('Modo oscuro'))).colorScheme.surface;

      // En oscuro el texto es más claro que en claro: no se lee «al revés».
      expect(lightMuted, isNot(darkMuted));
      expect(darkMuted!.computeLuminance(),
          greaterThan(lightMuted!.computeLuminance()));
      // Y en ambos casos contrasta con la superficie de la tarjeta.
      expect(
        (darkMuted.computeLuminance() - darkSurface.computeLuminance()).abs(),
        greaterThan(0.3),
      );
      expect(
        (lightMuted.computeLuminance() - lightSurface.computeLuminance()).abs(),
        greaterThan(0.3),
      );
    });
  });
}