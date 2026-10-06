// settings_section_label.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';

/// Encabezado de bloque en Configuración.
///
/// El texto llega ya traducido desde `SettingsCopy`; aquí solo se aplica el
/// estilo de la casa (versalitas, primario, peso w800). El separador de dos
/// píxeles mantiene la misma línea base que el mosaico de la fila que le sigue.
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}