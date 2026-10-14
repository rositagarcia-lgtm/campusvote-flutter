/// Enlaces de la web que abren la app (App Links de Android):
///
/// * `/ferias/:fairId/proyectos/:projectId` — QR del stand.
/// * `/j/invitacion?token=…` — invitación de jurado externo.
///
/// Si llegan con la app cerrada o sin sesión, el router los guarda aquí y los
/// retoma al terminar el arranque o el inicio de sesión.
class PendingDeepLink {
  PendingDeepLink._();

  static String? _location;

  static void remember(String location) => _location = location;

  /// Devuelve el enlace pendiente y lo olvida (se usa una sola vez).
  static String? take() {
    final value = _location;
    _location = null;
    return value;
  }

  static bool get hasInvitation => _location?.startsWith('/j/') ?? false;
  static bool get hasAny => _location != null;
}

bool isAppLink(String path) =>
    path.startsWith('/ferias/') || path.startsWith('/j/');

/// `(fairId, projectId)` de un QR de stand, o `null` si el texto no lo es.
/// Acepta la URL completa (lo que lee la cámara) o solo la ruta.
(String, String)? parseStandQr(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null) return null;
  final segments = uri.pathSegments;
  if (segments.length == 4 &&
      segments[0] == 'ferias' &&
      segments[2] == 'proyectos' &&
      segments[1].isNotEmpty &&
      segments[3].isNotEmpty) {
    return (segments[1], segments[3]);
  }
  return null;
}
