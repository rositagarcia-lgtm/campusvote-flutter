import 'package:flutter/material.dart';

import '../branding/organization_branding.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  /// Tema claro. Si hay branding institucional resuelto, pinta los colores de
  /// la organización; si no, usa la paleta por defecto de CampusVote.
  static ThemeData light({OrganizationBranding? branding}) {
    final primary = branding?.primaryColor;
    final secondary = branding?.secondaryColor;
    final scheme = ColorScheme.light(
      primary: primary ?? AppColors.primary,
      onPrimary: AppColors.inkInverse,
      secondary: secondary ?? AppColors.accent,
      onSecondary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.danger,
      onError: AppColors.inkInverse,
    );

    return _build(scheme, AppColors.background, AppColors.ink, Brightness.light);
  }

  static ThemeData dark({OrganizationBranding? branding}) {
    final primary = branding?.primaryColor;
    final secondary = branding?.secondaryColor;
    final scheme = ColorScheme.dark(
      primary: primary ?? AppColors.primaryLighter,
      onPrimary: AppColors.darkInkInverse,
      secondary: secondary ?? AppColors.accent,
      onSecondary: AppColors.darkInk,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkInk,
      error: AppColors.danger,
      onError: AppColors.inkInverse,
    );

    return _build(scheme, AppColors.darkBackground, AppColors.darkInk, Brightness.dark);
  }

  static ThemeData _build(
    ColorScheme scheme,
    Color background,
    Color surfaceInk,
    Brightness brightness,
  ) {
    final textTheme = AppTypography.buildTextTheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: surfaceInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLarge,
          side: BorderSide(
            color: brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.border,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.rMedium,
          borderSide: BorderSide(
            color: brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.rMedium,
          borderSide: BorderSide(
            color: brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.rMedium,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.rMedium,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: brightness == Brightness.dark
              ? AppColors.darkInkFaint
              : AppColors.inkFaint,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rMedium),
          textStyle: textTheme.titleSmall,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          side: BorderSide(color: scheme.primary, width: 1.4),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rMedium),
          textStyle: textTheme.titleSmall,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.titleSmall,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: brightness == Brightness.dark
            ? AppColors.darkBorder
            : AppColors.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceInk,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: brightness == Brightness.dark ? AppColors.darkInk : AppColors.inkInverse,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rMedium),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rLarge),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}