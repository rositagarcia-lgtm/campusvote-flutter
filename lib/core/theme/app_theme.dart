import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import '../branding/organization_branding.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';
import 'brand_colors.dart';

class AppTheme {
  const AppTheme._();

  /// Tema claro. Si hay branding institucional resuelto, pinta los colores de
  /// la organización; si no, usa la paleta por defecto de CampusVote.
  static ThemeData light({OrganizationBranding? branding}) =>
      _build(_Palette.resolve(branding, Brightness.light));

  static ThemeData dark({OrganizationBranding? branding}) =>
      _build(_Palette.resolve(branding, Brightness.dark));

  static ThemeData _build(_Palette p) {
    final isDark = p.brightness == Brightness.dark;
    final textTheme = AppTypography.buildTextTheme(p.brightness);

    // `fromSeed` genera contenedores, superficies y estados tonales a partir
    // del color de la organización. Sin esto `ColorScheme.light()` dejaba
    // `primaryContainer`, `outline` y `onSurfaceVariant` con valores genéricos
    // (el propio primario o la tinta), y los chips, interruptores y
    // segmentados se veían duros o fuera de marca.
    final seeded = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: p.brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    );
    final scheme = seeded.copyWith(
      primary: p.primary,
      onPrimary: BrandContrast.onColor(p.primary),
      secondary: p.secondary,
      onSecondary: BrandContrast.onColor(p.secondary),
      surface: p.surface,
      onSurface: p.ink,
      onSurfaceVariant: p.inkMuted,
      surfaceContainerLowest: p.surface,
      outline: p.borderStrong,
      outlineVariant: p.border,
      error: AppColors.danger,
      onError: AppColors.inkInverse,
    );

    final buttonShape =
        const RoundedRectangleBorder(borderRadius: AppRadii.rMedium);

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLarge,
          side: BorderSide(color: p.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.rMedium,
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.rMedium,
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.rMedium,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.rMedium,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        prefixIconColor: p.inkMuted,
        suffixIconColor: p.inkMuted,
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.inkFaint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: buttonShape,
          textStyle: textTheme.titleSmall,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: buttonShape,
          textStyle: textTheme.titleSmall,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          side: BorderSide(color: scheme.primary, width: 1.4),
          shape: buttonShape,
          textStyle: textTheme.titleSmall,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.titleSmall,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size.square(AppDimensions.touchTarget),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rXLarge),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: p.border),
        labelStyle: textTheme.labelLarge,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? scheme.onPrimary : null),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? scheme.primary : null),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.transparent
                : p.borderStrong),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rSmall),
        side: BorderSide(color: p.borderStrong, width: 1.5),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor:
            scheme.primary.withValues(alpha: isDark ? 0.24 : 0.14),
        circularTrackColor: Colors.transparent,
        linearMinHeight: 4,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.inkMuted,
        textColor: p.ink,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rMedium),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.ink,
          borderRadius: AppRadii.rSmall,
        ),
        textStyle: textTheme.labelMedium?.copyWith(color: p.surface),
        waitDuration: const Duration(milliseconds: 400),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.danger,
        textColor: AppColors.inkInverse,
        textStyle: textTheme.labelSmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.24 : 0.14),
        indicatorShape: const StadiumBorder(),
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              size: AppDimensions.iconLarge,
              color: states.contains(WidgetState.selected)
                  ? scheme.primary
                  : p.inkMuted,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? scheme.primary : p.inkMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0.1,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: p.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: p.surface),
        actionTextColor: isDark ? AppColors.primary : AppColors.accentLight,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rMedium),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rXLarge),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLarge,
          side: BorderSide(color: p.border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.borderStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}

/// Paleta resuelta para un brillo y una organización concretos.
///
/// La marca CampusVote usa sus neutros fijos. Una organización, en cambio,
/// recibe neutros con un 3–4 % de su primario mezclado: el fondo "huele" a la
/// institución sin restar legibilidad, y su primario se corrige si no alcanza
/// contraste suficiente sobre la superficie (p. ej. azul marino en oscuro).
class _Palette {
  const _Palette({
    required this.brightness,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.border,
    required this.borderStrong,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
  });

  final Brightness brightness;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color border;
  final Color borderStrong;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;

  static _Palette resolve(OrganizationBranding? branding, Brightness b) {
    final isDark = b == Brightness.dark;
    final isOrg = branding != null && branding.id != 'campusvote';
    final rawPrimary = branding?.primaryColor ??
        (isDark ? AppColors.primaryLighter : AppColors.primary);
    final secondary = branding?.secondaryColor ?? AppColors.accent;

    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final background = isDark ? AppColors.darkBackground : AppColors.background;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final borderStrong =
        isDark ? AppColors.darkBorderStrong : AppColors.borderStrong;

    Color tint(Color base, double amount) => isOrg
        ? Color.alphaBlend(rawPrimary.withValues(alpha: amount), base)
        : base;

    // En claro la tarjeta sigue siendo blanca; en oscuro se tiñe con la marca.
    final resolvedSurface =
        isOrg && isDark ? tint(const Color(0xFF181C1F), 0.06) : surface;

    return _Palette(
      brightness: b,
      primary: BrandContrast.ensure(rawPrimary, resolvedSurface),
      secondary: secondary,
      background: isOrg
          ? tint(isDark ? const Color(0xFF0F1214) : const Color(0xFFF7F8FA),
              isDark ? 0.05 : 0.035)
          : background,
      surface: resolvedSurface,
      border: isOrg
          ? tint(
              isDark ? const Color(0xFF2A3034) : const Color(0xFFE3E7EC), 0.08)
          : border,
      borderStrong: isOrg
          ? tint(
              isDark ? const Color(0xFF3B4247) : const Color(0xFFCBD2DA), 0.08)
          : borderStrong,
      ink: isDark ? AppColors.darkInk : AppColors.ink,
      inkMuted: isDark ? AppColors.darkInkMuted : AppColors.inkMuted,
      inkFaint: isDark ? AppColors.darkInkFaint : AppColors.inkFaint,
    );
  }
}
