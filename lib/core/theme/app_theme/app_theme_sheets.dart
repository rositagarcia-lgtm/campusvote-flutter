part of '../app_theme.dart';

/// Hojas inferiores: superficie de la paleta, asa visible y esquinas amplias.
BottomSheetThemeData _bottomSheetTheme(_Palette p) => BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: p.borderStrong,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
