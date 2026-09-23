import 'package:flutter/material.dart';


/// Radios estándar.
class AppRadii {
  const AppRadii._();
  static const double small = 6;
  static const double medium = 8;
  static const double large = 12;
  static const double xLarge = 16;

  static const BorderRadius rSmall = BorderRadius.all(Radius.circular(small));
  static const BorderRadius rMedium = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius rLarge = BorderRadius.all(Radius.circular(large));
  static const BorderRadius rXLarge = BorderRadius.all(Radius.circular(xLarge));
}

/// Espaciado consistente (grid de 4).
class AppSpacing {
  const AppSpacing._();
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppDimensions {
  const AppDimensions._();
  static const double iconSmall = 16;
  static const double iconMedium = 20;
  static const double iconLarge = 24;
  static const double touchTarget = 44;
  static const double inputHeight = 52;
  static const double buttonHeight = 52;
}