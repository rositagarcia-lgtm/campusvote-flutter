import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_skeleton.dart';

/// Mantiene la forma de la bandeja mientras llegan los avisos del servidor.
class NotificationsLoadingView extends StatelessWidget {
  const NotificationsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Cargando avisos',
      liveRegion: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          const AppSkeleton(width: 118, height: 12),
          const SizedBox(height: AppSpacing.s),
          const AppSkeleton(width: 205, height: 19),
          const SizedBox(height: AppSpacing.xl),
          for (var index = 0; index < 3; index++) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: AppRadii.rLarge,
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(
                    width: 44,
                    height: 44,
                    borderRadius: AppRadii.rMedium,
                  ),
                  SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeleton(width: 86, height: 10),
                        SizedBox(height: AppSpacing.s),
                        AppSkeleton(height: 17),
                        SizedBox(height: AppSpacing.s),
                        AppSkeleton(height: 12),
                        SizedBox(height: AppSpacing.xs),
                        AppSkeleton(width: 120, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ],
      ),
    );
  }
}
