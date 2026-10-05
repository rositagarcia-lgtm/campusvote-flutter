import 'package:flutter/material.dart';

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
    foregroundColor: ink,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
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
