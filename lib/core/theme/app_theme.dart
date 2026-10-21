import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import '../branding/organization_branding.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';
import 'brand_colors.dart';

part 'app_theme/app_theme_builder.dart';
part 'app_theme/app_theme_palette.dart';

class AppTheme {
  const AppTheme._();

  /// Tema claro. Si hay branding institucional resuelto, pinta los colores de
  /// la organización; si no, usa la paleta por defecto de CampusVote.
  static ThemeData light({OrganizationBranding? branding}) =>
      _build(_Palette.resolve(branding, Brightness.light));

  static ThemeData dark({OrganizationBranding? branding}) =>
      _build(_Palette.resolve(branding, Brightness.dark));

  static ThemeData _build(_Palette palette) => _AppThemeBuilder.build(palette);
}
