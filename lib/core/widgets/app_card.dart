import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'app_palette.dart';

/// Tarjeta plana: superficie limpia con borde fino de 1 px y radio contenido.
///
/// No lleva sombra: el sistema reserva la elevación para la barra de
/// navegación flotante. [elevated] se conserva por compatibilidad y ya no
/// añade sombra.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
    this.bordered = true,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final bool bordered;

  /// Ignorado a propósito: las tarjetas del sistema son planas.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final card = Container(
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: AppRadii.rLarge,
        border: bordered
            ? Border.all(color: borderColor ?? appBorder(isDark))
            : null,
      ),
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.l,
          ),
      child: child,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.rLarge,
        child: card,
      ),
    );
  }
}
