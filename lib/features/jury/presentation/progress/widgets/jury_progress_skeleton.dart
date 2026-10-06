import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_page_layout.dart';
import '../../../../../core/widgets/app_skeleton.dart';
import 'jury_panel.dart';

/// Estructura de la pantalla mientras llegan los datos.
///
/// Replica la composición real (dos tarjetas + lista de etapas) para que la
/// transición a los datos no dé un salto de layout.
class JuryProgressSkeleton extends StatelessWidget {
  const JuryProgressSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScrollBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SkeletonPanel(height: 132),
          SizedBox(height: AppSpacing.l),
          _SkeletonPanel(height: 196),
          SizedBox(height: AppSpacing.xl),
          AppSkeleton(height: AppSpacing.m, width: 168),
          SizedBox(height: AppSpacing.m),
          _SkeletonPanel(height: 148),
          SizedBox(height: AppSpacing.m),
          _SkeletonPanel(height: 148),
          SizedBox(height: AppSpacing.m),
          _SkeletonPanel(height: 148),
        ],
      ),
    );
  }
}

class _SkeletonPanel extends StatelessWidget {
  const _SkeletonPanel({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const JuryPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeleton(height: AppSpacing.m, width: 148),
            SizedBox(height: AppSpacing.l),
            AppSkeleton(height: AppSpacing.l),
            SizedBox(height: AppSpacing.m),
            AppSkeleton(height: 64, width: double.infinity),
          ],
        ),
      ),
    );
  }
}
