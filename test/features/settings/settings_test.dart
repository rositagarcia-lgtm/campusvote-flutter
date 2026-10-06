import 'package:campusvote_flutter/core/di/core_providers.dart';
import 'package:campusvote_flutter/core/settings/app_preferences.dart';
import 'package:campusvote_flutter/core/storage/local_storage.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_page.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:campusvote_flutter/features/auth/presentation/widgets/auth_form_widgets.dart'
    as auth_widgets;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('errores del servidor no revelan roles ni detalles técnicos', () {
    const spanish = SettingsCopy(AppLanguage.spanish);
    const english = SettingsCopy(AppLanguage.english);

    expect(
      spanish.error(
        'No se encontró una cuenta de estudiante o jurado con este correo',
      ),
      'No encontramos una cuenta habilitada para este acceso. Verifica que uses el correo registrado en CampusVote.',
    );
    expect(
      english.error(
          'No se encontró una cuenta de estudiante o jurado con este correo'),
      'We could not find an account enabled for this sign-in. Check that you are using the email registered with CampusVote.',
    );
    expect(
      spanish.error('Prisma TypeError at /api/auth/email/request'),
      'Ocurrió un error inesperado',
    );
    expect(
        spanish.error('Escribe un correo válido'), 'Escribe un correo válido');
  });

  test('las preferencias persisten y se recuperan al reiniciar', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorage.create();
    final first = ProviderContainer(overrides: [
      localStorageProvider.overrideWithValue(storage),
    ]);
    await first.read(appPreferencesProvider.notifier).setDarkMode(true);
    await first
        .read(appPreferencesProvider.notifier)
        .setTextSize(AppTextSize.large);
    await first
        .read(appPreferencesProvider.notifier)
        .setLanguage(AppLanguage.english);
    first.dispose();

    final second = ProviderContainer(overrides: [
      localStorageProvider.overrideWithValue(storage),
    ]);
    addTearDown(second.dispose);
    final restored = second.read(appPreferencesProvider);
    expect(restored.darkMode, isTrue);
    expect(restored.textSize, AppTextSize.large);
    expect(restored.language, AppLanguage.english);
  });

  testWidgets('configuración cambia tema e idioma sin desbordarse',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorage.create();
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(storage)],
      child: Consumer(builder: (context, ref, _) {
        final settings = ref.watch(appPreferencesProvider);
        return MaterialApp(
          locale: Locale(settings.language.code),
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => AppLanguageScope(
            language: settings.language,
            child: child!,
          ),
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode:
              settings.darkMode == true ? ThemeMode.dark : ThemeMode.light,
          home: const SettingsPage(),
        );
      }),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Configuración'), findsOneWidget);
    await tester.tap(find.text('Grande'));
    await tester.pumpAndSettle();
    expect(storage.getString('settings.text_size'), 'large');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.byType(SettingsPage))).brightness,
        Brightness.dark);

    await tester.ensureVisible(find.text('English'));
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Text size'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'el idioma guardado se aplica en el primer frame fuera de Configuración',
      (tester) async {
    SharedPreferences.setMockInitialValues({'settings.language': 'en'});
    final storage = await LocalStorage.create();
    await tester.pumpWidget(ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(storage)],
      child: Consumer(builder: (context, ref, _) {
        final language = ref.watch(appPreferencesProvider).language;
        return MaterialApp(
          builder: (context, child) => AppLanguageScope(
            language: language,
            child: child!,
          ),
          home: Scaffold(body: Builder(builder: (context) {
            final text = SettingsCopy.of(context);
            return Column(children: [
              Text(text.t('Sobre mí')),
              Text(text.t('Panel del jurado')),
              Text(text.t('Cerrar sesión')),
            ]);
          })),
        );
      }),
    ));
    await tester.pumpAndSettle();
    expect(find.text('About me'), findsOneWidget);
    expect(find.text('Jury Panel'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el acceso cabe en claro/oscuro y en los tres tamaños de texto',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final language in AppLanguage.values) {
      for (final dark in [false, true]) {
        for (final size in AppTextSize.values) {
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) => AppLanguageScope(
              language: language,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(size.factor),
                ),
                child: child!,
              ),
            ),
            home: Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Builder(builder: (context) {
                    final text = SettingsCopy.of(context);
                    return auth_widgets.AuthHeader(
                      accent: Theme.of(context).colorScheme.primary,
                      icon: Icons.security_rounded,
                      overline: text.t('Verificación en dos pasos'),
                      title: text.t('Ingresa tu código'),
                      subtitle: text.t(
                          'Ingresa el código de 6 dígitos de tu aplicación autenticadora.'),
                    );
                  }),
                ),
              ),
            ),
          ));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: '${language.code}, dark=$dark, size=$size');
        }
      }
    }
  });
}
