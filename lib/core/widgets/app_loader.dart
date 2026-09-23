import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

/// Loader institucional (CampusVote spinner).
class AppLoader extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoader({super.key, this.message, this.size = 36, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(color ?? colorScheme.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}