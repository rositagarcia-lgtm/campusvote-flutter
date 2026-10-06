// notification_date_header.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';

/// Encabezado de un grupo de avisos por día: la etiqueta del grupo y su
/// contador alineados a la línea base.
///
/// Reemplaza el `Text` suelto que se escribía dentro de la página para que el
/// agrupamiento se lea igual que el resto de encabezados de la app.
class NotificationDateHeader extends StatelessWidget {
  const NotificationDateHeader({
    super.key,
    required this.label,
    required this.count,
  });

  /// Grupo ya traducido y en mayúsculas (HOY, AYER, dd/MM/yyyy).
  final String label;

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Semantics(
      header: true,
      child: ExcludeSemantics(
        child: Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            // Une visualmente la etiqueta con su lista sin añadir una línea.
            Expanded(
              child: Container(
                height: 1,
                color: theme.dividerColor,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}