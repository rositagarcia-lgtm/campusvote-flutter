// app_icon_tile.dart

import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

/// Mosaico de ícono: cuadro tintado con el color de marca o de estado.
///
/// Comparte el lenguaje visual de `ActionTile`, pero en la medida pequeña que
/// usan las filas de ajustes y de avisos. El tinte sube en oscuro para que el
/// ícono no se apague contra la superficie.
///
/// El ícono es decorativo: se excluye de la semántica porque el nombre lo da
/// el texto que lo acompaña.
class AppIconTile extends StatelessWidget {
  const AppIconTile({
    super.key,
    required this.icon,
    required this.color,
    this.extent = defaultExtent,
    this.iconSize = AppDimensions.iconMedium,
    this.radius = AppRadii.rMedium,
  });

  final IconData icon;

  /// Color del mosaico: primario institucional, o el del tono del estado.
  final Color color;

  /// Lado del cuadro. [defaultExtent] es la medida de las filas.
  final double extent;

  final double iconSize;

  final BorderRadius radius;

  /// Lado por defecto. Los grupos lo usan para sangrar sus divisores.
  static const double defaultExtent = 40;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ExcludeSemantics(
      child: Container(
        width: extent,
        height: extent,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.18 : 0.10),
          borderRadius: radius,
        ),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}