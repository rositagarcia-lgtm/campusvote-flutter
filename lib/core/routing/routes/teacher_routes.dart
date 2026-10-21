part of '../app_router.dart';

List<RouteBase> _teacherRoutes(WidgetRef ref) => [
      // �"?�"? DOCENTE: inicio propio y resultados de su evaluación �"?�"?�"?�"?�"?�"?�"?�"?�"?
      GoRoute(
        path: '/teacher',
        pageBuilder: (_, s) => _tabPage(s, const TeacherHomePage()),
        routes: [
          GoRoute(
            path: 'evaluation',
            pageBuilder: (_, s) => _tabPage(s, const TeacherResultsPage()),
          ),
          GoRoute(
            path: 'projects',
            builder: (_, __) => const AdviserProjectsPage(),
            routes: [
              GoRoute(
                path: ':projectId',
                builder: (_, s) => AdviserProjectDetailPage(
                  projectId: s.pathParameters['projectId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ];
