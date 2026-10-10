import 'dart:math' as math;

import 'package:campusvote_flutter/app/splash_intro_video.dart';
import 'package:campusvote_flutter/app/splash_page.dart';
import 'package:campusvote_flutter/app/welcome_language_selector.dart';
import 'package:campusvote_flutter/core/di/core_providers.dart';
import 'package:campusvote_flutter/core/settings/app_preferences.dart';
import 'package:campusvote_flutter/core/storage/local_storage.dart';
import 'package:campusvote_flutter/core/theme/app_colors.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:campusvote_flutter/core/theme/app_icons.dart';

void main() {
  test('intro no confunde un valor inicial de duración cero con el final', () {
    const initial = VideoPlayerValue(
      duration: Duration.zero,
      isInitialized: true,
      isCompleted: true,
    );
    const playing = VideoPlayerValue(
      duration: Duration(seconds: 4),
      isInitialized: true,
      isPlaying: true,
    );
    const completed = VideoPlayerValue(
      duration: Duration(seconds: 4),
      isInitialized: true,
      isCompleted: true,
      position: Duration(seconds: 4),
    );
    expect(hasIntroPlaybackCompleted(initial, started: true), isFalse);
    expect(hasIntroPlaybackCompleted(playing, started: true), isFalse);
    expect(hasIntroPlaybackCompleted(completed, started: false), isFalse);
    expect(hasIntroPlaybackCompleted(completed, started: true), isTrue);
  });

  testWidgets('el video mantiene cover, centro y fondo oscuro en cada tamaño',
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
              child: IntroVideoFrame(
                aspectRatio: aspectRatio,
                child: const ColoredBox(
                  key: ValueKey('video-content'),
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ));

        final rect =
            tester.getRect(find.byKey(const ValueKey('video-content')));
        expect(tester.getSize(find.byType(IntroVideoFrame)), size);
        expect(rect.width / rect.height, closeTo(aspectRatio, 0.001));
        expect(rect.center.dx, closeTo(size.width / 2, 0.01));
        expect(rect.center.dy, closeTo(size.height / 2, 0.01));
        final coverHeight = math.max(size.height, size.width / aspectRatio);
        final scale = rect.height / coverHeight;
        expect(scale, inInclusiveRange(0.92 - 0.001, 1.0 + 0.001));
        if ((aspectRatio - size.width / size.height).abs() > 0.1) {
          expect(scale, lessThan(0.99));
        }
        expect(
          find.byWidgetPredicate((widget) =>
              widget is ColoredBox && widget.color == AppColors.darkBackground),
          findsOneWidget,
        );
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
    await tester.tap(find.byIcon(PhosphorIconsRegular.globe));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-option-en')));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.byKey(const ValueKey('language-panel')), findsOneWidget);
    expect(
      tester
          .widget<Semantics>(find.byKey(const ValueKey('language-option-en')))
          .properties
          .selected,
      isTrue,
    );
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
    await tester.tap(find.byIcon(PhosphorIconsRegular.globe));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-option-es')));
    await tester.pumpAndSettle();
    expect(find.text('Elige cómo participar'), findsOneWidget);
    expect(storage.getString('settings.language'), 'es');
    expect(tester.takeException(), isNull);
  });

  testWidgets('panel compacto y accesible en ambos temas e idiomas',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorage.create();
    final container = ProviderContainer(overrides: [
      localStorageProvider.overrideWithValue(storage),
    ]);
    addTearDown(container.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in [
      const Size(320, 568),
      const Size(390, 844),
      const Size(480, 1000),
    ]) {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        for (final language in AppLanguage.values) {
          await container
              .read(appPreferencesProvider.notifier)
              .setLanguage(language);
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          await tester.pumpWidget(UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primary,
                  brightness: brightness,
                ),
              ),
              builder: (context, child) => AppLanguageScope(
                language: language,
                child: child!,
              ),
              home: const Scaffold(
                body: SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: WelcomeLanguageSelector(),
                    ),
                  ),
                ),
              ),
            ),
          ));
          await tester.pumpAndSettle();

          final button = find.byKey(const ValueKey('welcome-language-button'));
          expect(tester.getSize(button), const Size(44, 44));
          await tester.tap(button);
          await tester.pumpAndSettle();
          final panel = find.byKey(const ValueKey('language-panel'));
          final rect = tester.getRect(panel);
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThanOrEqualTo(size.height));
          expect(
              find.text(
                  language == AppLanguage.spanish ? 'Idioma' : 'Language'),
              findsOneWidget);
          expect(
              find.text(
                  language == AppLanguage.spanish ? 'Español' : 'Spanish'),
              findsOneWidget);
          expect(find.text('English'), findsOneWidget);
          expect(
            tester
                .widget<Semantics>(find.byKey(ValueKey(
                  'language-option-${language.code}',
                )))
                .properties
                .selected,
            isTrue,
          );
          expect(tester.takeException(), isNull);
          await tester.tap(button);
          await tester.pumpAndSettle();
        }
      }
    }
  });
}
