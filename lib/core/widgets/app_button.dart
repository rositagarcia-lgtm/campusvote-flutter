import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'app_palette.dart';

enum AppButtonVariant { primary, outlined, danger, ghost }

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
  });

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.dense = false,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.dense = false,
  }) : variant = AppButtonVariant.danger;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.dense = false,
  }) : variant = AppButtonVariant.ghost;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  /// Altura compacta para contextos tight (diálogos, barras de acciones).
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disabled = onPressed == null || isLoading;
    final rule = appBorder(isDark);

    final Color bg;
    final Color fg;
    final BorderSide side;
    switch (variant) {
      case AppButtonVariant.primary:
        bg = disabled ? Colors.transparent : theme.colorScheme.primary;
        fg = disabled ? appFaint(isDark) : theme.colorScheme.onPrimary;
        side = disabled ? BorderSide(color: rule) : BorderSide.none;
      case AppButtonVariant.outlined:
        bg = Colors.transparent;
        fg = disabled ? appFaint(isDark) : theme.colorScheme.primary;
        side = BorderSide(color: disabled ? rule : theme.colorScheme.primary);
      case AppButtonVariant.danger:
        bg = disabled ? Colors.transparent : AppColors.danger;
        fg = disabled ? appFaint(isDark) : AppColors.inkInverse;
        side = disabled ? BorderSide(color: rule) : BorderSide.none;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = disabled ? appFaint(isDark) : theme.colorScheme.primary;
        side = BorderSide.none;
    }

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            height: AppDimensions.iconSmall,
            width: AppDimensions.iconSmall,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(fg),
            ),
          )
        else if (icon != null)
          Icon(icon, size: AppDimensions.iconMedium, color: fg),
        if (isLoading || icon != null) const SizedBox(width: AppSpacing.s),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.rMedium,
        side: side,
      ),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: AppRadii.rMedium,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                dense ? AppDimensions.touchTarget : AppDimensions.buttonHeight,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: dense ? AppSpacing.s : AppSpacing.m,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
