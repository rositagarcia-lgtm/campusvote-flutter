import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/app_bootstrap.dart';
import 'core/analytics/app_analytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppAnalytics.init();
  final overrides = await appBootstrapOverrides();
  runApp(
    ProviderScope(
      overrides: overrides,
      child: const CampusVoteApp(),
    ),
  );
}
