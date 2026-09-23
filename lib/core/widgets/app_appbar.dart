import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

/// AppBar reutilizable para mantener consistencia.
PreferredSizeWidget buildCampusVoteAppBar(
  BuildContext context, {
  String? title,
  List<Widget>? actions,
  Widget? leading,
}) {
  return AppBar(
    title: Text(title ?? 'CampusVote'),
    centerTitle: false,
    leading: leading,
    actions: actions,
  );
}

const campusVoteAppBarHeight = kToolbarHeight + AppSpacing.l;