import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografía consistente con Roboto.
class AppTypography {
  const AppTypography._();

  static TextTheme buildTextTheme(Brightness brightness) {
    final base = GoogleFonts.robotoTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );

    TextStyle style(double size, FontWeight weight, Color color,
        {double? height, double? letterSpacing}) {
      return base.bodyMedium!.copyWith(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }

    final ink =
        brightness == Brightness.dark ? AppColors.darkInk : AppColors.ink;
    final inkMuted = brightness == Brightness.dark
        ? AppColors.darkInkMuted
        : AppColors.inkMuted;

    return TextTheme(
      displayLarge: style(40, FontWeight.w700, ink),
      displayMedium: style(32, FontWeight.w700, ink),
      displaySmall: style(28, FontWeight.w700, ink),
      headlineLarge: style(24, FontWeight.w700, ink),
      headlineMedium: style(22, FontWeight.w700, ink),
      headlineSmall: style(20, FontWeight.w600, ink),
      titleLarge: style(18, FontWeight.w600, ink),
      titleMedium: style(16, FontWeight.w600, ink),
      titleSmall: style(14, FontWeight.w600, ink),
      bodyLarge: style(16, FontWeight.w400, ink, height: 1.4),
      bodyMedium: style(14, FontWeight.w400, inkMuted, height: 1.4),
      bodySmall: style(13, FontWeight.w400, inkMuted, height: 1.4),
      labelLarge: style(13, FontWeight.w600, ink, letterSpacing: 0.2),
      labelMedium: style(12, FontWeight.w600, inkMuted, letterSpacing: 0.4),
      labelSmall: style(11, FontWeight.w600, inkMuted, letterSpacing: 0.5),
    );
  }

  static const double display = 40;
  static const double title = 32;
  static const double heading = 24;
  static const double subheading = 18;
  static const double paragraph = 16;
  static const double caption = 14;
  static const double label = 13;
  static const double micro = 12;
}
