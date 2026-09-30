/// Traduce las rutas antiguas del panel de jurado (`/juries/fairs/...`) a las
/// nuevas (`/jury/fair/...`).
///
/// El módulo `features/fair_voting` fue reemplazado por `features/jury`, que
/// cubre el mismo flujo y además el progreso, la declaración de imparcialidad
/// y los resultados. Para no romper enlaces guardados (notificaciones por
/// correo, accesos corto de otros dispositivos) el router global redirige en
/// lugar de dejar un 404.
///
/// | antigua                                | nueva                                          |
/// |----------------------------------------|------------------------------------------------|
/// | `/juries`                              | `/jury`                                        |
/// | `/juries/fairs`                        | `/jury`                                        |
/// | `/juries/fairs/:fairId/projects`       | `/jury/fair/:fairId`                           |
/// | `/juries/fairs/:fairId/projects/:id/rubric` | `/jury/fair/:fairId/project/:id/rubric`  |
/// | `/juries/fairs/:fairId/voting`         | `/jury/fair/:fairId/vote`                      |
/// | `/juries/fairs/:fairId/voting/success` | `/jury/fair/:fairId/vote`                      |
///
/// Devuelve `null` cuando la ruta no pertenece al panel legado, para no
/// interferir con el resto de la navegación.
String? legacyJuryRedirect(String location) {
  final segments = Uri.parse(location).pathSegments;
  if (segments.isEmpty || segments.first != 'juries') return null;

  // `/juries` y cualquier ruta que no entre por `fairs` caen al dashboard.
  if (segments.length == 1) return '/jury';
  if (segments[1] != 'fairs' || segments.length == 2) return '/jury';

  final base = '/jury/fair/${segments[2]}';
  final tail = segments.sublist(3);

  if (tail.isEmpty) return base;
  if (tail.length == 1) {
    return switch (tail.first) {
      'projects' => base,
      'voting' => '$base/vote',
      _ => base,
    };
  }
  if (tail.length == 3 && tail[0] == 'projects' && tail[2] == 'rubric') {
    return '$base/project/${tail[1]}/rubric';
  }
  // El segundo intento de voto y el recibo ya se muestran dentro de
  // `VotingPage`, así que la pantalla de éxito heredada no tiene equivalente.
  if (tail.length == 2 && tail[0] == 'voting' && tail[1] == 'success') {
    return '$base/vote';
  }
  return base;
}

/// Indica si [location] pertenece al panel del jurado.
///
/// Se usa en el guard de rol para impedir que un ADMIN o un STUDENT abra la
/// UI del jurado (el backend igual rechaza las peticiones).
bool isJuryPanelPath(String location) {
  final segments = Uri.parse(location).pathSegments;
  return segments.isNotEmpty && segments.first == 'jury';
}
