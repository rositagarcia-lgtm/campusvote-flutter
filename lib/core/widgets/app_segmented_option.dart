// app_segmented_option.dart

import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

/// Variante visual de una opción segmentada.
enum AppSegmentStyle {
  /// Fondo tenue y borde de marca: para muestras comparables (tamaño de texto).
  outline,

  /// Relleno sólido al elegir: para opciones excluyentes (idioma, filtros).
  filled,
}

/// Opción segmentada: etiqueta, muestra opcional, contador y estado.
///
/// Un solo control en toda la app. Elegir un tamaño de texto, un idioma o un
/// filtro de proyectos se siente igual porque son el mismo widget, con la misma
/// zona táctil, el mismo borde y la misma semántica.
class AppSegmentOption extends StatelessWidget {
  const AppSegmentOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.preview,
    this.count,
    this.style = AppSegmentStyle.outline,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Muestra sobre la etiqueta (por ejemplo, «Aa»). Se excluye de la
  /// semántica: el lector de pantalla debe oír la etiqueta, no el adorno.
  final Widget? preview;

  /// Contador opcional, mostrado como una píldora aparte para que se lea sin
  /// quedar pegado al nombre.
  final int? count;

  final AppSegmentStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filled = style == AppSegmentStyle.filled;
    final primary = theme.colorScheme.primary;
    final total = count;

    final Color background;
    final Color borderColor;
    final Color selectedInk;
    if (filled) {
      background = selected ? primary : Colors.transparent;
      borderColor = selected ? primary : theme.dividerColor;
      selectedInk = theme.colorScheme.onPrimary;
    } else {
      background = selected
          ? primary.withValues(alpha: isDark ? 0.20 : 0.10)
          : Colors.transparent;
      borderColor = selected ? primary : theme.dividerColor;
      selectedInk = primary;
    }

    // El contador entra en la etiqueta de semántica para que el número no
    // dependa de que se anuncie el texto suelto de la píldora.
    final semanticsLabel =
        total == null ? label : '$label, $total';

    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rMedium,
          side: BorderSide(color: borderColor, width: selected ? 1.5 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: AppDimensions.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: AppSpacing.m,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (preview != null) ...[
                    preview!,
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: selected ? selectedInk : null,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (total != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        _CountBadge(total: total, selected: selected, filled: filled),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Píldora del contador dentro de una opción segmentada.
class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.total,
    required this.selected,
    required this.filled,
  });

  final int total;
  final bool selected;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final background = filled
        ? (selected
            ? theme.colorScheme.onPrimary.withValues(alpha: 0.24)
            : primary.withValues(alpha: isDark ? 0.20 : 0.10))
        : primary.withValues(alpha: isDark ? 0.20 : 0.10);
    final foreground = filled && selected ? theme.colorScheme.onPrimary : primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 1),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.rSmall,
      ),
      child: Text(
        '$total',
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}