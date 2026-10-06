// notification_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_tile.dart';
import '../../../core/widgets/app_palette.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../notification_item.dart';
import 'notification_type.dart';

/// Lado del mosaico de la tarjeta.
///
/// Público porque el cuerpo de la tarjeta se sangra con el mismo valor: si el
/// mosaico cambia, el texto sigue alineado sin tocar dos números a mano.
const double notificationCardIconExtent = 44;

/// Tarjeta de un aviso.
///
/// Sigue el patrón de las filas de la app: mosaico de ícono a la izquierda,
/// sobretítulo teñido con el tono del tipo, título en negrita y mensaje en tono
/// secundario. No lleva sombra —el sistema reserva la elevación para la barra
/// de navegación—: lo no leído se marca con el borde de acento y el punto.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.loading,
    required this.onTap,
  });

  final NotificationItem notification;

  /// Marca el aviso como «en proceso» (marcar como leída) y bloquea el toque.
  final bool loading;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final type = notificationType(notification.type);
    final tone = appToneColors(
      type.tone,
      isDark: isDark,
      primary: theme.colorScheme.primary,
    );
    final read = notification.isRead;

    return Semantics(
      button: true,
      enabled: !loading,
      label: '${type.label}. ${notification.title}. '
          '${read ? 'Leída' : 'No leída'}',
      excludeSemantics: true,
      child: AppCard(
        borderColor: read ? appBorder(isDark) : tone.fg.withValues(alpha: 0.35),
        onTap: loading ? null : onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIconTile(
                  icon: type.icon,
                  color: tone.fg,
                  extent: notificationCardIconExtent,
                  iconSize: AppDimensions.iconLarge,
                  radius: AppRadii.rLarge,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              type.label.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: tone.fg,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          if (loading)
                            SizedBox(
                              width: AppDimensions.iconSmall,
                              height: AppDimensions.iconSmall,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: tone.fg,
                              ),
                            )
                          else if (!read)
                            // El estado no se comunica solo con color: el punto
                            // acompaña siempre al peso del título.
                            _UnreadDot(color: tone.fg),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: read ? FontWeight.w600 : FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // El cuerpo cuelga del bloque del ícono, no de su esquina: el texto
            // queda en una sola columna y no se descentra al cambiar de ancho.
            Padding(
              padding: const EdgeInsets.only(
                left: notificationCardIconExtent + AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.message.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appMuted(isDark),
                        height: 1.45,
                      ),
                    ),
                  ],
                  if (notification.createdAt case final date?) ...[
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      DateFormat('dd/MM/yyyy · HH:mm').format(date.toLocal()),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: appFaint(isDark),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Punto de aviso no leído.
///
/// Puramente decorativo: la tarjeta lee el estado en su etiqueta de `Semantics`
/// («… No leída»), así que un segundo nodo aquí se anunciaría dos veces.
class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.s),
      child: Container(
        width: AppSpacing.s,
        height: AppSpacing.s,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}