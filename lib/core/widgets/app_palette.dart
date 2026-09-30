import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Helpers de color compartido por toda la capa de presentación.
///
/// Todo widget debe verse igual de bien en claro y en oscuro, así que el
/// texto secundario y el borde fino nunca se escriben a mano: se resuelven
/// aquí.

/// Color de texto secundario (descripciones, metadatos, sobretítulos).
Color appMuted(bool isDark) =>
    isDark ? AppColors.darkInkMuted : AppColors.inkMuted;

/// Color de texto terciario (pistas, marcas de agua de estado).
Color appFaint(bool isDark) =>
    isDark ? AppColors.darkInkFaint : AppColors.inkFaint;

/// Color del borde fino de 1 px de las tarjetas planas.
Color appBorder(bool isDark) =>
    isDark ? AppColors.darkBorder : AppColors.primarySoft;

/// Superficie de tarjeta: blanca en claro, `darkSurface` en oscuro.
Color appSurface(BuildContext context) => Theme.of(context).colorScheme.surface;
