import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

enum AppButtonVariant { primary, outlined, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.danger;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disabled = onPressed == null || isLoading;

    final bg = switch (variant) {
      AppButtonVariant.primary => AppColors.primary,
      AppButtonVariant.outlined => Colors.transparent,
      AppButtonVariant.danger => AppColors.danger,
      AppButtonVariant.ghost => Colors.transparent,
    };

    final fg = switch (variant) {
      AppButtonVariant.primary => AppColors.inkInverse,
      AppButtonVariant.outlined => AppColors.primary,
      AppButtonVariant.danger => AppColors.inkInverse,
      AppButtonVariant.ghost =>
        isDark ? AppColors.darkInk : AppColors.primary,
    };

    Widget content = Row(
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
        else if (icon != null) ...[
          Icon(icon, size: AppDimensions.iconMedium, color: fg),
        ],
        if (isLoading || icon != null) const SizedBox(width: AppSpacing.s),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: disabled
                ? (isDark ? AppColors.darkInkFaint : AppColors.inkFaint)
                : fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final shape = RoundedRectangleBorder(
      borderRadius: AppRadii.rMedium,
      side: variant == AppButtonVariant.outlined
          ? const BorderSide(color: AppColors.primary, width: 1.4)
          : BorderSide.none,
    );

    return Material(
      color: bg,
      shape: shape,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: AppRadii.rMedium,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.buttonHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.m,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}