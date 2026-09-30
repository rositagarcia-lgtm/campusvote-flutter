import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

/// AppBar reutilizable para mantener consistencia.
///
/// El título es obligatorio: cada pantalla debe nombrarse sola (sin marcar
/// "CampusVote" por defecto) para que el branding institucional sea coherente.
PreferredSizeWidget buildCampusVoteAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  Widget? leading,
}) {
  return AppBar(
    title: Text(title),
    centerTitle: false,
    leading: leading,
    actions: actions,
  );
}

const campusVoteAppBarHeight = kToolbarHeight + AppSpacing.l;