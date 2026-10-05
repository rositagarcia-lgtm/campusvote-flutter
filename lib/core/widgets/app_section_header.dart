import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'app_palette.dart';

/// Encabezado de sección: sobretítulo en mayúsculas, título opcional,
/// descripción y contador en una píldora de borde fino.
///
/// Reemplaza los tres encabezados que tenía la app (encabezado de feria,
/// etiqueta de sección de seguridad y encabezado del selector de acceso) para
/// que la jerarquía tipográfica sea la misma en todas las pantallas.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.label,
    this.title,
    this.subtitle,
    this.count,
    this.trailing,
    this.divider = false,
  });

  /// Sobretítulo en mayúsculas (bloque, rol o etapa del flujo).
  final String label;

  /// Título en serif; si es nulo, el sobretítulo hace de encabezado.
  final String? title;

  /// Descripción en tono secundario.
  final String? subtitle;

  /// Número de elementos de la sección; se muestra en una píldora.
  final int? count;

  /// Elemento opcional a la derecha (acción, etiqueta).
  final Widget? trailing;

  /// Añade un divisor fino bajo el encabezado.
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = appMuted(isDark);
    final rule = appBorder(isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: AppSpacing.s),
                _CountPill(count: count!),
              ],
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.s),
                trailing!,
              ],
            ],
          ),
          if (title != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              title!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
          if (divider) ...[
            const SizedBox(height: AppSpacing.m),
            Divider(height: 1, thickness: 1, color: rule),
          ],
        ],
      ),
    );
  }
}

/// Contador de la sección dentro de una píldora de borde fino.
class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;

    return Semantics(
      label: '$count elementos',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AppDimensions.touchTarget * 0.5,
          minHeight: AppDimensions.touchTarget * 0.5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.2 : 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          '$count',
          style: theme.textTheme.labelSmall?.copyWith(
            color: accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
