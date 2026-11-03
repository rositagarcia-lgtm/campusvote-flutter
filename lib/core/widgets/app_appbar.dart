import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../../features/settings/presentation/settings_copy.dart';
import 'translatable_text.dart';

/// AppBar reutilizable para mantener consistencia.
///
/// El título es obligatorio: cada pantalla debe nombrarse sola (sin marcar
/// "CampusVote" por defecto) para que el branding institucional sea coherente.
PreferredSizeWidget buildCampusVoteAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  Widget? leading,
  bool content = false,
}) {
  final style = Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      );
  return AppBar(
    title: content
        ? TranslatableText(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          )
        : Text(SettingsCopy.of(context).t(title), style: style),
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    leading: leading,
    actions: actions,
  );
}

const campusVoteAppBarHeight = kToolbarHeight + AppSpacing.l;
