import 'package:campusvote_flutter/app/splash_intro_video.dart';
import 'package:campusvote_flutter/app/splash_page.dart';
import 'package:campusvote_flutter/core/di/core_providers.dart';
import 'package:campusvote_flutter/core/settings/app_preferences.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/core/storage/local_storage.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('el video conserva proporción, límites y centro en cada tamaño',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final size in [
      const Size(320, 568),
      const Size(390, 844),
      const Size(480, 1000),
    ]) {
      for (final aspectRatio in [9 / 16, 16 / 9]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(
                size: size,
                padding: const EdgeInsets.only(top: 24, bottom: 32),
              ),
              child: SafeArea(
                child: IntroVideoFrame(
                  aspectRatio: aspectRatio,
                  child: const ColoredBox(
                    key: ValueKey('video-content'),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ));

        final rect =
            tester.getRect(find.byKey(const ValueKey('video-content')));
        expect(rect.width, lessThanOrEqualTo(size.width * 0.88 + 0.01));
        expect(
            rect.height, lessThanOrEqualTo((size.height - 56) * 0.75 + 0.01));
        expect((size.height - 56 - rect.height) / 2,
            greaterThanOrEqualTo(AppSpacing.xxxl + AppSpacing.l - 0.01));
        expect(rect.width / rect.height, closeTo(aspectRatio, 0.001));
        expect(rect.center.dx, closeTo(size.width / 2, 0.01));
        expect(rect.center.dy, closeTo(24 + (size.height - 56) / 2, 0.01));
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('idioma de bienvenida actualiza accesos y conserva preferencia',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'settings.theme': 'dark',
      'settings.text_size': 'small',
    });
    final storage = await LocalStorage.create();
    final router = GoRouter(initialLocation: '/splash', routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(
        path: '/auth/email-request',
        builder: (context, _) => Scaffold(
          body: Text(SettingsCopy.of(context).t('Acceso con código')),
        ),
      ),
      GoRoute(
        path: '/auth/jury/login',
        builder: (context, _) => Scaffold(
          body: Text(SettingsCopy.of(context).t('Portal del jurado')),
        ),
      ),
    ]);
    addTearDown(router.dispose);

    await tester.pumpWidget(ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(storage)],
      child: Consumer(builder: (context, ref, _) {
        final language = ref.watch(appPreferencesProvider).language;
        return MaterialApp.router(
          routerConfig: router,
          locale: Locale(language.code),
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => AppLanguageScope(
            language: language,
            child: child!,
          ),
        );
      }),
    ));
    await tester.pumpAndSettle();
    if (find.text('Omitir introducción').evaluate().isNotEmpty) {
      await tester.tap(find.text('Omitir introducción'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Elige cómo participar'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate(
      (widget) =>
          widget is CheckedPopupMenuItem<AppLanguage> &&
          widget.value == AppLanguage.english,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Choose how to participate'), findsOneWidget);
    expect(storage.getString('settings.language'), 'en');
    expect(storage.getString('settings.theme'), 'dark');
    expect(storage.getString('settings.text_size'), 'small');

    await tester.ensureVisible(find.text('Continue with my email'));
    await tester.tap(find.text('Continue with my email'));
    await tester.pumpAndSettle();
    expect(find.text('Code-based access'), findsOneWidget);

    router.go('/splash');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign in as jury'));
    await tester.tap(find.text('Sign in as jury'));
    await tester.pumpAndSettle();
    expect(find.text('Jury portal'), findsOneWidget);

    router.go('/splash');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate(
      (widget) =>
          widget is CheckedPopupMenuItem<AppLanguage> &&
          widget.value == AppLanguage.spanish,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Elige cómo participar'), findsOneWidget);
    expect(storage.getString('settings.language'), 'es');
    expect(tester.takeException(), isNull);
  });
}
