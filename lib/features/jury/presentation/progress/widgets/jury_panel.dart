import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_palette.dart';

/// Superficie base de las tarjetas de la pantalla de progreso.
///
/// Sin sombra ni degradados: la jerarquía la llevan el borde fino, el radio y
/// la tipografía, igual que el resto del panel.
class JuryPanel extends StatelessWidget {
  const JuryPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(
          color: appBorder(theme.brightness == Brightness.dark),
        ),
      ),
      child: child,
    );
  }
}

/// Cuadro tintado con el ícono de una etapa o de una etiqueta de estado.
class JuryPanelIcon extends StatelessWidget {
  const JuryPanelIcon({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: AppDimensions.touchTarget,
      height: AppDimensions.touchTarget,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.18 : 0.10,
        ),
        borderRadius: AppRadii.rMedium,
      ),
      child: Icon(icon, color: color, size: AppDimensions.iconLarge),
    );
  }
}

/// Fila de metadatos con ícono (sede, estado) en tono secundario.
class JuryMetaRow extends StatelessWidget {
  const JuryMetaRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = appMuted(theme.brightness == Brightness.dark);
    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconSmall, color: muted),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Sobretítulo en versalitas de un bloque de la pantalla.
class JuryOverline extends StatelessWidget {
  const JuryOverline({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: appMuted(theme.brightness == Brightness.dark),
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
