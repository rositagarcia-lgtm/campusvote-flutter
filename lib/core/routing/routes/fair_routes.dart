part of '../app_router.dart';

List<RouteBase> _fairRoutes(WidgetRef ref) => [
      // Enlaces de la web que abren la aplicación.
      // QR del stand: cada rol llega a su vista del proyecto.
      GoRoute(
        path: '/ferias/:fairId/proyectos/:projectId',
        redirect: (_, s) {
          final fairId = s.pathParameters['fairId']!;
          final projectId = s.pathParameters['projectId']!;
          final role = ref.read(authControllerProvider).user?.role;
          if (role == AuthRole.student) {
            return '/teaching/projects/$projectId?fair=$fairId';
          }
          // El QR del stand es para el alumno (opinar); el jurado y el
          // docente califican desde su panel, no por QR.
          return landingPathForRole(role);
        },
      ),
      // Resultados publicados de una feria (todos los roles).
      GoRoute(
        path: '/resultados/:fairId',
        builder: (_, s) =>
            PublishedResultsPage(fairId: s.pathParameters['fairId']!),
      ),
      // Certificados de feria del usuario (descarga en PDF).
      GoRoute(
        path: '/certificados',
        // Apagado por ahora (AppFeatures.studentCertificates): vuelve al inicio.
        redirect: (_, __) => AppFeatures.studentCertificates
            ? null
            : landingPathForRole(ref.read(authControllerProvider).user?.role),
        builder: (_, __) => const MyCertificatesPage(),
      ),
      // Escáner del QR del stand (cualquier rol con sesión).
      GoRoute(path: '/scan', builder: (_, __) => const ScanStandPage()),
      GoRoute(
        path: '/j/invitacion',
        builder: (_, s) => JuryInvitationPage(
          token: s.uri.queryParameters['token'] ?? '',
        ),
      ),
    ];
