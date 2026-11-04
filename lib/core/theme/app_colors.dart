import 'package:flutter/material.dart';

/// Paleta oficial CampusVote (modo claro y oscuro).
class AppColors {
  const AppColors._();

  // Claro. Verde oscuro de la app. El azul del docente es el cian tenue
  // de la página pública (#59D8EE).
  static const Color primary = Color(0xFF14532D);
  static const Color primaryDark = Color(0xFF0C3B22);
  static const Color primaryLight = Color(0xFF1F6B45);
  static const Color primaryLighter = Color(0xFF3D9A6A);
  static const Color primarySoft = Color(0xFFE7F3EC);
  static const Color primarySubtle = Color(0xFFF4F8F6);

  static const Color accent = Color(0xFFFF7189);
  static const Color accentLight = Color(0xFF59D8EE);
  static const Color accentSoft = Color(0xFFFFF0F3);

  // Acentos de los accesos de la bienvenida. No sustituyen el branding
  // institucional de los paneles autenticados.
  static const Color studentAccess = Color(0xFF14532D);
  static const Color teacherAccess = Color(0xFF59D8EE);
  static const Color teacherAccessInk = Color(0xFF006C7A);
  static const Color juryAccess = Color(0xFFFF7189);
  static const Color juryAccessInk = Color(0xFF17112E);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF4F7F5);
  static const Color border = Color(0xFFD4E2DA);
  static const Color borderStrong = Color(0xFFB4C9BE);

  static const Color ink = Color(0xFF14241C);
  static const Color inkMuted = Color(0xFF4E6158);
  static const Color inkFaint = Color(0xFF6E8178);
  static const Color inkInverse = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFDBEAFE);

  // Dark overrides
  static const Color darkSurface = Color(0xFF16241E);
  static const Color darkBackground = Color(0xFF0E1713);
  static const Color darkBorder = Color(0xFF2C4036);
  static const Color darkBorderStrong = Color(0xFF3D5649);
  static const Color darkInk = Color(0xFFF3F7F4);
  static const Color darkInkMuted = Color(0xFFC3D4CB);
  static const Color darkInkFaint = Color(0xFF96AFA4);
  static const Color darkInkInverse = Color(0xFF14241C);
  static const Color darkPrimarySoft = Color(0xFF1C332A);
  static const Color darkPrimarySubtle = Color(0xFF15261F);
  static const Color darkDangerSoft = Color(0xFF4A2023);
  static const Color darkWarningSoft = Color(0xFF4A3918);
  static const Color darkInfoSoft = Color(0xFF1F3559);
}
