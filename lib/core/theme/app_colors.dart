import 'package:flutter/material.dart';

/// Paleta oficial CampusVote (modo claro y oscuro).
class AppColors {
  const AppColors._();

  // Light. Misma paleta pública de la web, antes de la institución.
  static const Color primary = Color(0xFF4D3BE4);
  static const Color primaryDark = Color(0xFF3929B7);
  static const Color primaryLight = Color(0xFF6657F5);
  static const Color primaryLighter = Color(0xFFA49BFF);
  static const Color primarySoft = Color(0xFFE9E7FF);
  static const Color primarySubtle = Color(0xFFF4F3FF);

  static const Color accent = Color(0xFFFF7189);
  static const Color accentLight = Color(0xFFDDFA67);
  static const Color accentSoft = Color(0xFFFFF0F3);

  // Acentos de los dos accesos de la bienvenida. No sustituyen el branding
  // institucional de los paneles autenticados.
  static const Color studentAccess = Color(0xFF4D3BE4);
  static const Color juryAccess = Color(0xFFFF7189);
  static const Color juryAccessInk = Color(0xFF17112E);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F6FF);
  static const Color border = Color(0xFFDCD9ED);
  static const Color borderStrong = Color(0xFFBDB8DF);

  static const Color ink = Color(0xFF17152F);
  static const Color inkMuted = Color(0xFF55536B);
  static const Color inkFaint = Color(0xFF73718C);
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
  static const Color darkSurface = Color(0xFF211F3D);
  static const Color darkBackground = Color(0xFF10112E);
  static const Color darkBorder = Color(0xFF454164);
  static const Color darkBorderStrong = Color(0xFF5B5682);
  static const Color darkInk = Color(0xFFF7F5FF);
  static const Color darkInkMuted = Color(0xFFC2BFDC);
  static const Color darkInkFaint = Color(0xFFA5A1C2);
  static const Color darkInkInverse = Color(0xFF17152F);
  static const Color darkPrimarySoft = Color(0xFF33305E);
  static const Color darkPrimarySubtle = Color(0xFF292649);
  static const Color darkDangerSoft = Color(0xFF4A2023);
  static const Color darkWarningSoft = Color(0xFF4A3918);
  static const Color darkInfoSoft = Color(0xFF1F3559);
}
