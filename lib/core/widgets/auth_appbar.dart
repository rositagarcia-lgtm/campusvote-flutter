import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../../features/settings/presentation/settings_copy.dart';

/// AppBar transparente de los flujos de acceso, con botón de volver.
///
/// El destino del botón lo decide la pantalla: los pasos del acceso siempre
/// regresan al selector de perfiles, nunca a un panel concreto.
PreferredSizeWidget buildAuthAppBar(
  BuildContext context, {
  required VoidCallback onBack,
  List<Widget>? actions,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final ink = isDark ? AppColors.darkInk : AppColors.ink;

  return AppBar(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle:
        isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    foregroundColor: ink,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    leading: IconButton(
      icon: const Icon(PhosphorIconsRegular.arrowLeft),
      color: ink,
      tooltip: SettingsCopy.of(context).t('Volver'),
      onPressed: onBack,
      constraints: const BoxConstraints(
        minWidth: AppDimensions.touchTarget,
        minHeight: AppDimensions.touchTarget,
      ),
    ),
    actions: actions,
  );
}

/// Etiqueta contextual para identificar el paso o el tipo de acceso.
class AuthAppBarBadge extends StatelessWidget {
  const AuthAppBarBadge({
    super.key,
    required this.accent,
    required this.label,
    this.icon,
  });

  final Color accent;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.22 : 0.08),
      theme.colorScheme.surface,
    );

    return Semantics(
      label: label,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 184, minHeight: 32),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == null)
              Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(color: accent, shape: BoxShape.circle),
              )
            else
              Icon(icon, size: AppDimensions.iconSmall, color: accent),
            const SizedBox(width: AppSpacing.s),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
