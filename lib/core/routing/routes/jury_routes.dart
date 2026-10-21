part of '../app_router.dart';

List<RouteBase> _juryRoutes(WidgetRef ref) => [
      // Panel y evaluaciones del jurado.
      // Árbol canónico del panel de jurado. Las rutas `/juries/**` se
      // resuelven por el redirect global de `legacyJuryRedirect`.
      GoRoute(
        path: '/jury',
        pageBuilder: (_, s) => _tabPage(s, const JuryDashboardPage()),
        routes: [
          GoRoute(
            path: 'notifications',
            builder: (_, __) => const NotificationsPage(),
          ),
          GoRoute(
            path: 'fair/:fairId',
            builder: (_, s) =>
                FairProjectsPage(fairId: s.pathParameters['fairId']!),
            routes: [
              GoRoute(
                path: 'project/:projectId',
                builder: (_, s) => JuryProjectDetailPage(
                  fairId: s.pathParameters['fairId']!,
                  projectId: s.pathParameters['projectId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'rubric',
                    builder: (_, s) => RubricEvaluationPage(
                      fairId: s.pathParameters['fairId']!,
                      projectId: s.pathParameters['projectId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'progress',
                builder: (_, s) =>
                    JuryProgressPage(fairId: s.pathParameters['fairId']!),
              ),
              GoRoute(
                path: 'declaration',
                builder: (_, s) =>
                    JuryDeclarationPage(fairId: s.pathParameters['fairId']!),
              ),
              GoRoute(
                path: 'vote',
                builder: (_, s) =>
                    VotingPage(fairId: s.pathParameters['fairId']!),
              ),
            ],
          ),
        ],
      ),
    ];
