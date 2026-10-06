import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, outlined, danger, ghost }

/// Botón de acción de la app.
///
/// Un solo botón primario por pantalla, con ícono; el estado deshabilitado se
/// comunica con texto atenuado y borde fino, no solo con opacidad.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.dense = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.dense = false,
  })  : variant = AppButtonVariant.outlined,
        backgroundColor = null,
        foregroundColor = null;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.dense = false,
  })  : variant = AppButtonVariant.danger,
        backgroundColor = null,
        foregroundColor = null;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.dense = false,
  })  : variant = AppButtonVariant.ghost,
        backgroundColor = null,
        foregroundColor = null;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Altura compacta para contextos tight (diálogos, barras de acciones).
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onPressed == null || isLoading;
    final foreground = foregroundColor ?? switch (variant) {
      AppButtonVariant.primary => theme.colorScheme.onPrimary,
      AppButtonVariant.secondary => theme.colorScheme.onSecondary,
      AppButtonVariant.danger => AppColors.inkInverse,
      AppButtonVariant.outlined ||
      AppButtonVariant.ghost =>
        theme.colorScheme.primary,
    };

    final content = Semantics(
      liveRegion: isLoading,
      label: isLoading ? 'Procesando' : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              height: AppDimensions.iconSmall,
              width: AppDimensions.iconSmall,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(foreground),
              ),
            )
          else if (icon != null)
            Icon(icon, size: AppDimensions.iconMedium),
          if (isLoading || icon != null) const SizedBox(width: AppSpacing.s),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: theme.textTheme.labelLarge?.fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );

    const shape = RoundedRectangleBorder(borderRadius: AppRadii.rMedium);
    final minimumSize = Size(expand ? double.infinity : 0, dense ? 48 : 52);
    final padding = const EdgeInsets.symmetric(horizontal: AppSpacing.l);
    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          child: content,
        ),
      AppButtonVariant.secondary => FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            backgroundColor: backgroundColor ?? theme.colorScheme.secondary,
            foregroundColor: foregroundColor ?? theme.colorScheme.onSecondary,
          ),
          child: content,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: content,
        ),
      AppButtonVariant.danger => FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            backgroundColor: AppColors.danger,
            foregroundColor: AppColors.inkInverse,
          ),
          child: content,
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
          ),
          child: content,
        ),
    };

    return button;
  }
}
