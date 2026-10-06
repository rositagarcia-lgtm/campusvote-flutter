// settings_group.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_icon_tile.dart';
import '../../../../core/widgets/app_palette.dart';

/// Tarjeta que apila filas separadas por un divisor fino de 1 px.
///
/// Sustituye a varias tarjetas sueltas: las filas de un mismo bloque comparten
/// superficie, de modo que el grupo se lee como una sola unidad. El divisor
/// arranca en el borde del texto (icono + separación) y no en el del borde de
/// la tarjeta, que es como se alinean las listas agrupadas del sistema.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  /// Sangría del divisor: padding de la tarjeta + mosaico + su separación.
  static const double dividerInset =
      AppSpacing.l + AppIconTile.defaultExtent + AppSpacing.m;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rule = appBorder(isDark);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: rule),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.only(left: dividerInset),
                child: Divider(height: 1, thickness: 1, color: rule),
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}

/// Encabezado de una tarjeta de Configuración: título y descripción.
///
/// Se usa dentro de [SettingsGroup] para los bloques que no son una fila
/// conmutable (tamaño de texto, idioma), donde hace falta explicar la
/// elección además de nombrarla.
class SettingsGroupHeader extends StatelessWidget {
  const SettingsGroupHeader({
    super.key,
    required this.title,
    required this.hint,
  });

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hint,
            style: theme.textTheme.bodySmall?.copyWith(color: appMuted(isDark)),
          ),
        ],
      ),
    );
  }
}

/// Contenedor con el padding lateral de la tarjeta para los controles que
/// siguen a un [SettingsGroupHeader] (los grupos de opciones).
class SettingsGroupBody extends StatelessWidget {
  const SettingsGroupBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        0,
        AppSpacing.l,
        AppSpacing.l,
      ),
      child: child,
    );
  }
}