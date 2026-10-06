import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/branding/branding_controller.dart';
import '../core/routing/app_router.dart';
import '../core/settings/app_preferences.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/settings_copy.dart';

class CampusVoteApp extends ConsumerStatefulWidget {
  const CampusVoteApp({super.key});

  @override
  ConsumerState<CampusVoteApp> createState() => _CampusVoteAppState();
}

class _CampusVoteAppState extends ConsumerState<CampusVoteApp> {
  late final GoRouterRefreshNotifier _refreshNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // El router se construye UNA sola vez. Reconstruirlo en cada `build` (o
    // cuando cambia el branding) reiniciaba el GoRouter y perdía el estado de
    // navegación —el usuario quedaba de vuelta en el splash tras cada login.
    _refreshNotifier = GoRouterRefreshNotifier(ref);
    _router = buildAppRouter(ref, refreshListenable: _refreshNotifier);
  }

  @override
  void dispose() {
    _router.dispose();
    _refreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branding = ref.watch(brandingControllerProvider);
    final preferences = ref.watch(appPreferencesProvider);
    return MaterialApp.router(
      title: 'CampusVote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(branding: branding),
      darkTheme: AppTheme.dark(branding: branding),
      themeMode: switch (preferences.darkMode) {
        true => ThemeMode.dark,
        false => ThemeMode.light,
        null => ThemeMode.system,
      },
      locale: Locale(preferences.language.code),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final systemUiStyle = SystemUiOverlayStyle(
          statusBarColor: theme.scaffoldBackgroundColor,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: theme.colorScheme.surface,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: theme.colorScheme.outlineVariant,
        );
        if (preferences.textSize == AppTextSize.normal) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: systemUiStyle,
            child: AppLanguageScope(
              language: preferences.language,
              child: child!,
            ),
          );
        }
        final media = MediaQuery.of(context);
        final factor = (media.textScaler.scale(1) * preferences.textSize.factor)
            .clamp(0.85, 1.6);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiStyle,
          child: MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(factor)),
            child: AppLanguageScope(
              language: preferences.language,
              child: child!,
            ),
          ),
        );
      },
      routerConfig: _router,
    );
  }
}
