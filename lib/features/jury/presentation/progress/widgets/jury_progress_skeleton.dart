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
          _SkeletonPanel(minHeight: 132),
          SizedBox(height: AppSpacing.l),
          _SkeletonPanel(minHeight: 196),
          SizedBox(height: AppSpacing.xl),
          _SkeletonLine(maxWidth: 168),
          SizedBox(height: AppSpacing.m),
          _SkeletonPanel(minHeight: 148),
          SizedBox(height: AppSpacing.m),
          _SkeletonPanel(minHeight: 148),
          SizedBox(height: AppSpacing.m),
          _SkeletonPanel(minHeight: 148),
        ],
      ),
    );
  }
}

class _SkeletonPanel extends StatelessWidget {
  const _SkeletonPanel({required this.minHeight});

  /// Altura mínima que conserva el ritmo visual aprobado. No es una altura
  /// fija: el contenido (padding, borde y bloques internos) manda y puede
  /// crecer, así ninguna tarjeta recorta su último bloque.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: const JuryPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonLine(maxWidth: 148),
            SizedBox(height: AppSpacing.l),
            AppSkeleton(height: AppSpacing.l),
            SizedBox(height: AppSpacing.m),
            AppSkeleton(height: 64),
          ],
        ),
      ),
    );
  }
}

/// Línea de carga que no supera el ancho disponible en pantallas estrechas.
class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({this.maxWidth});

  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: const AppSkeleton(height: AppSpacing.m),
    );
  }
}
