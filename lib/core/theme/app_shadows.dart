import 'package:flutter/material.dart';

/// Sombras globales reutilizables.
class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get campus => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 4),
          blurRadius: 6,
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.05),
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ];

  static List<BoxShadow> get card => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.06),
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.05),
          offset: Offset(0, 4),
          blurRadius: 12,
        ),
      ];

  static List<BoxShadow> get none => const [];
}

extension ShadowedOnWidget on Widget {
  Widget campusShadow() => Container(
      decoration: BoxDecoration(boxShadow: AppShadows.campus), child: this);
}
