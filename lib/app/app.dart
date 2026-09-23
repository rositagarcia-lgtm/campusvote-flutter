import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';

class CampusVoteApp extends ConsumerWidget {
  const CampusVoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = buildAppRouter(ref);
    return MaterialApp.router(
      title: 'CampusVote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}