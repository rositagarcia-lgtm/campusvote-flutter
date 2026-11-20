// progress_banner_skeleton.dart

import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_dimensions.dart';

/// Skeleton del banner de progreso mientras carga.
class ProgressBannerSkeleton extends StatelessWidget {
  const ProgressBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: AppRadii.rSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppRadii.rSmall,
          ),
        ),
      ],
    );
  }
}