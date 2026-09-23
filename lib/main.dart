import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = await appBootstrapOverrides();
  runApp(
    ProviderScope(
      overrides: overrides,
      child: const CampusVoteApp(),
    ),
  );
}