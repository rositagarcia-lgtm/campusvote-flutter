part of '../app_theme.dart';

class _AppThemeBuilder {
  static ThemeData build(_Palette p) {
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
      // iOS: sin onda al tocar y controles Cupertino con el color de marca.
      splashFactory: _isApple ? NoSplash.splashFactory : InkSparkle.splashFactory,
      cupertinoOverrideTheme: CupertinoThemeData(primaryColor: p.primary),
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
      bottomSheetTheme: _bottomSheetTheme(p),
    );
  }
}
