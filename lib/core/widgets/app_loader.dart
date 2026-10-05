import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'app_palette.dart';
import '../../features/settings/presentation/settings_copy.dart';

/// Loader institucional: spinner fino con mensaje en tono secundario.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.message, this.size = 36, this.color});

  final String? message;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(
                  color ?? theme.colorScheme.primary,
                ),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.m),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  SettingsCopy.of(context).t(message!),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: appMuted(isDark),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
