import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/branding/branding_controller.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';

class CampusVoteApp extends ConsumerStatefulWidget {
  const CampusVoteApp({super.key});

  @override
  ConsumerState<CampusVoteApp> createState() => _CampusVoteAppState();
}

class _CampusVoteAppState extends ConsumerState<CampusVoteApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // El router se construye UNA sola vez. Reconstruirlo en cada `build` (o
    // cuando cambia el branding) reiniciaba el GoRouter y perdía el estado de
    // navegación —el usuario quedaba de vuelta en el splash tras cada login.
    _router = buildAppRouter(ref);
  }

  @override
  Widget build(BuildContext context) {
    final branding = ref.watch(brandingControllerProvider);
    return MaterialApp.router(
      title: 'CampusVote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(branding: branding),
      darkTheme: AppTheme.dark(branding: branding),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}