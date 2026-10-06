import 'package:campusvote_flutter/core/di/core_providers.dart';
import 'package:campusvote_flutter/core/settings/app_preferences.dart';
import 'package:campusvote_flutter/core/storage/local_storage.dart';
import 'package:campusvote_flutter/core/theme/app_theme.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Monta Configuración con el tema real de la app y tamaño de pantalla
/// variable.
///
/// Reproduce lo que hace `App`: el tema del branding, la escala de texto de la
/// preferencia y el `AppLanguageScope`. Las pruebas de detalle lo reutilizan
/// para no duplicar este montaje.
Future<ProviderContainer> pumpSettings(
  WidgetTester tester, {
  Size size = const Size(360, 800),
  bool dark = false,
  String? storedLanguage,
  AppTextSize storedTextSize = AppTextSize.normal,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({
    if (storedLanguage != null) 'settings.language': storedLanguage,
    if (storedTextSize != AppTextSize.normal) 'settings.text_size': storedTextSize.name,
  });
  final storage = await LocalStorage.create();
  final container = ProviderContainer(
    overrides: [localStorageProvider.overrideWithValue(storage)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(builder: (context, ref, _) {
        final preferences = ref.watch(appPreferencesProvider);
        return MaterialApp(
          locale: Locale(preferences.language.code),
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return AppLanguageScope(
              language: preferences.language,
              child: MediaQuery(
                data: media.copyWith(
                  // Igual que `App`: la preferencia escala todo el árbol.
                  textScaler: TextScaler.linear(
                    media.textScaler.scale(1) * preferences.textSize.factor,
                  ),
                ),
                child: child!,
              ),
            );
          },
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: const SettingsPage(),
        );
      }),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// `Semantics` de botón más cercano a [label], para leer sus propiedades.
Semantics semanticsButtonFor(WidgetTester tester, String label) => tester
    .widgetList<Semantics>(
      find.ancestor(of: find.text(label), matching: find.byType(Semantics)),
    )
    .firstWhere((node) => node.properties.button == true);