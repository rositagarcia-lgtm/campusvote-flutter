import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'app_palette.dart';

/// Identidad de la organización dentro de un panel.
///
/// Muestra el logo institucional y, si la organización todavía no tiene logo
/// o la URL falla, cae a sus iniciales: el panel nunca queda sin identidad.
class PanelHeroOrgBadge extends StatelessWidget {
  const PanelHeroOrgBadge({
    super.key,
    required this.name,
    this.logoUrl,
    this.accent,
  });

  final String name;
  final String? logoUrl;

  /// Color de marca con el que se pinta la inicial.
  final Color? accent;

  /// Iniciales de la organización (primera letra de las dos primeras palabras).
  static String initialsOf(String value) {
    final words =
        value.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final brand = accent ?? theme.colorScheme.primary;
    final url = logoUrl;

    return Container(
      width: AppSpacing.xxl,
      height: AppSpacing.xxl,
      padding: const EdgeInsets.all(AppSpacing.xs),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.rSmall,
        border: Border.all(color: appBorder(isDark)),
      ),
      child: (url == null || url.isEmpty)
          ? _Initials(name: name, brand: brand)
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _Initials(name: name, brand: brand),
            ),
    );
  }
}

/// Placeholder con la inicial del nombre, sobre fondo tintado.
class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.brand});

  final String name;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      image: true,
      label: 'Identidad de $name',
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: brand.withValues(alpha: isDark ? 0.18 : 0.10),
          borderRadius: AppRadii.rSmall,
        ),
        child: Text(
          PanelHeroOrgBadge.initialsOf(name),
          style: theme.textTheme.labelSmall?.copyWith(
            color: brand,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Tinta de marca legible sobre superficies claras.
Color heroInk(bool isDark) =>
    isDark ? AppColors.darkInk : AppColors.primaryDark;
