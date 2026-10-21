part of '../app_router.dart';

List<RouteBase> _studentRoutes(WidgetRef ref) => [
      // Evaluación docente y ferias del estudiante.
      GoRoute(
        path: '/teaching',
        pageBuilder: (_, s) => _tabPage(s, const TeachingHomePage()),
        routes: [
          // Público de la feria: el alumno califica y comenta proyectos.
          GoRoute(
            path: 'explore',
            pageBuilder: (_, s) => _tabPage(s, const ExploreFairsPage()),
            routes: [
              GoRoute(
                path: ':fairId',
                builder: (_, s) => AudienceProjectsPage(
                  fairId: s.pathParameters['fairId']!,
                  initialProjectId: s.uri.queryParameters['project'],
                ),
              ),
            ],
          ),
          // Proyectos de feria del alumno: módulo propio, separado del jurado.
          GoRoute(
            path: 'projects',
            pageBuilder: (_, s) => _tabPage(s, const StudentProjectsPage()),
            routes: [
              GoRoute(
                path: ':projectId',
                builder: (_, s) => StudentProjectDetailPage(
                  projectId: s.pathParameters['projectId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'evaluate/:assignmentId',
            builder: (_, s) => TeacherEvaluationPage(
              assignmentId: s.pathParameters['assignmentId']!,
            ),
            routes: [
              GoRoute(
                path: 'success',
                builder: (_, s) => TeacherEvaluationSuccessPage(
                  assignmentId: s.pathParameters['assignmentId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ];
