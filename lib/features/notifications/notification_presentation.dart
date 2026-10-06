// notification_presentation.dart — punto único de acceso a la capa visual.
//
// Los mapas y el agrupamiento viven separados por archivo; este solo reexporta
// para que el resto de la app importe una sola ruta.

export 'presentation/notification_filters.dart';
export 'presentation/notification_type.dart';

/// Etiqueta del grupo de un aviso según su día.
///
/// Compara días calendario en hora local, no horas transcurridas: un aviso de
/// las 23:59 de ayer sigue siendo «AYER» a las 00:10 de hoy.
String notificationDateGroup(DateTime? date, DateTime now) {
  if (date == null) return 'SIN FECHA';
  final local = date.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final days = today.difference(day).inDays;
  if (days == 0) return 'HOY';
  if (days == 1) return 'AYER';
  if (days > 1 && days < 7) return 'ESTA SEMANA';
  final formatted = '${day.day.toString().padLeft(2, '0')}/'
      '${day.month.toString().padLeft(2, '0')}/${day.year}';
  return formatted;
}