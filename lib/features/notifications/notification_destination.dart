import '../auth/domain/entities/auth_role.dart';

/// A dónde lleva un aviso al tocarlo.
///
/// Los resultados publicados no abren la lista de proyectos: con la feria
/// cerrada el servidor rechaza esa lista y la pantalla queda en error.
String? notificationPath({
  required String kind,
  required String? role,
  String? fairId,
  String? projectId,
}) {
  final fair = fairId?.trim() ?? '';
  final project = projectId?.trim() ?? '';
  if (kind == 'RESULTS_PUBLISHED' && fair.isNotEmpty) {
    return '/resultados/${Uri.encodeComponent(fair)}';
  }
  if (role == AuthRole.student && project.isNotEmpty &&
      (kind == 'RATING_RECEIVED' || kind == 'PROJECT_REVIEWED' || kind == 'PROJECT_COMMENTED')) {
    final query = fair.isEmpty ? '' : '?fair=${Uri.encodeComponent(fair)}';
    return '/teaching/projects/${Uri.encodeComponent(project)}$query';
  }
  if (fair.isEmpty) return null;
  if (role == AuthRole.student) {
    return '/teaching/explore/${Uri.encodeComponent(fair)}';
  }
  if (AuthRole.usesJuryPanel(role)) {
    return '/jury/fair/${Uri.encodeComponent(fair)}';
  }
  return null;
}
