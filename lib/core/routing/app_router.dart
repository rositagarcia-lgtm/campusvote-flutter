import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/splash_page.dart';
import '../../features/auth/domain/entities/auth_role.dart';
import '../../features/auth/presentation/pages/account_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/pages/email_otp_verify_page.dart';
import '../../features/auth/presentation/pages/email_request_page.dart';
import '../../features/auth/presentation/pages/jury_login_page.dart';
import '../../features/auth/presentation/pages/password_reset_request_page.dart';
import '../../features/auth/presentation/pages/security_page.dart';
import '../../features/auth/presentation/pages/totp_backup_codes_page.dart';
import '../../features/auth/presentation/pages/totp_page.dart';
import '../../features/auth/presentation/pages/totp_setup_page.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../../features/auth/presentation/state/auth_events.dart';
import '../../features/jury/presentation/pages/fair_projects_page.dart';
import '../../features/jury/presentation/pages/jury_dashboard_page.dart';
import '../../features/jury/presentation/pages/jury_declaration_page.dart';
import '../../features/jury/presentation/pages/jury_progress_page.dart';
import '../../features/jury/presentation/pages/rubric_evaluation_page.dart';
import '../../features/jury/presentation/pages/voting_page.dart';
import '../../features/notifications/notifications_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/teaching_evaluation/presentation/pages/teacher_evaluation_page.dart';
import '../../features/teaching_evaluation/presentation/pages/teacher_evaluation_success_page.dart';
import '../../features/student_projects/presentation/student_project_detail_page.dart';
import '../../features/student_projects/presentation/student_projects_page.dart';
import '../../features/teaching_evaluation/presentation/pages/teaching_home_page.dart';
import 'legacy_jury_routes.dart';
import 'role_landing.dart';

/// Router global.
///
/// Implementa guards:
/// - authenticated
/// - mustChangePassword → forzado a /security/password
/// - election in scope (vía controllers)
/// - voting session active (cuando aplique)
/// [refreshListenable] debe ser provisto por el llamador para poder liberarlo
/// junto con el widget dueño (GoRouter no lo descarta por sí mismo).
GoRouter buildAppRouter(
  WidgetRef ref, {
  required Listenable refreshListenable,
}) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      // El panel de jurado se renombró de `/juries/**` a `/jury/**`; los
      // enlaces guardados siguen funcionando gracias a esta traducción.
      final legacy = legacyJuryRedirect(loc);
      if (legacy != null) return legacy;

      if (auth.initializing) {
        return loc == '/splash' ? null : '/splash';
      }
      // '/splash' (bienvenida) es pública: quien no tiene sesión la ve.
      // Cada panel tiene su propio acceso: el del jurado pide contraseña y el
      // del estudiante pide un código por correo.
      const publicRoutes = {
        '/splash',
        '/login',
        '/auth/jury/login',
        '/auth/email-request',
        '/auth/email-verify',
        '/auth/password/forgot',
        '/auth/totp',
      };
      if (!auth.authenticated && !publicRoutes.contains(loc)) {
        return '/splash';
      }
      // Forzar cambio de contraseña obligatorio antes de cualquier otra ruta
      // (incluido el salto al panel de su rol).
      if (auth.authenticated &&
          auth.mustChangePassword &&
          loc != '/security/password') {
        if (loc == '/splash' && !SplashPage.introCompleted) return null;
        if (loc == '/splash') {
          debugPrint('[SplashIntro ${DateTime.now().toIso8601String()}] '
              'navigation.router destination=/security/password');
        }
        return '/security/password';
      }
      // Para usuarios autenticados, mandamos a la pantalla principal según
      // su rol. La autoridad es `user.role` del backend, no el panel que el
      // usuario tocó en el splash.
      if (auth.authenticated && publicRoutes.contains(loc)) {
        if (loc == '/splash' && !SplashPage.introCompleted) return null;
        final destination = landingPathForRole(auth.user?.role);
        if (loc == '/splash') {
          debugPrint('[SplashIntro ${DateTime.now().toIso8601String()}] '
              'navigation.router destination=$destination');
        }
        return destination;
      }
      // No renderizar un panel ajeno. El backend sigue siendo la autoridad
      // (rechaza las peticiones), pero evita mostrar la UI de otro rol.
      if (auth.authenticated) {
        final opensJuryPanel = isJuryPanelPath(loc);
        final opensStudentPanel = loc.startsWith('/teaching');
        final isJury = AuthRole.usesJuryPanel(auth.user?.role);
        final isStudent = auth.user?.role == AuthRole.student;
        if ((opensJuryPanel && !isJury) || (opensStudentPanel && !isStudent)) {
          return landingPathForRole(auth.user?.role);
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),

      // ── JURADO: correo + contraseña (credencial que envía el admin) ────
      GoRoute(
        path: '/auth/jury/login',
        builder: (_, __) => const JuryLoginPage(),
      ),
      GoRoute(
        path: '/auth/password/forgot',
        builder: (_, __) => const PasswordResetRequestPage(),
      ),

      // ── ESTUDIANTE: código de un solo uso por correo ───────────────────
      GoRoute(
        path: '/auth/email-request',
        builder: (_, __) => const EmailRequestPage(),
      ),

      GoRoute(
        path: '/auth/email-verify',
        builder: (_, __) => const EmailOtpVerifyPage(),
      ),
      // Enlace profundo heredado: el único acceso con contraseña es el del
      // jurado, así que se redirige en lugar de romper.
      GoRoute(
        path: '/login',
        redirect: (_, __) => '/auth/jury/login',
      ),
      GoRoute(
        path: '/account',
        pageBuilder: (_, s) => _tabPage(s, const AccountPage()),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      GoRoute(path: '/auth/totp', builder: (_, __) => const TotpPage()),
      GoRoute(
        path: '/security',
        builder: (_, __) => const SecurityPage(),
        routes: [
          GoRoute(
            path: 'password',
            builder: (_, s) => ChangePasswordPage(
              // El cambio forzado sale del estado de sesión, no de un stub.
              required: s.extra == true ||
                  ref.read(authControllerProvider).mustChangePassword,
            ),
          ),
          GoRoute(
            path: 'totp/setup',
            builder: (_, __) => const TotpSetupPage(),
          ),
          GoRoute(
            path: 'totp/backup-codes',
            builder: (_, s) {
              final codes = (s.extra is List)
                  ? (s.extra as List).map((e) => e.toString()).toList()
                  : <String>[];
              return TotpBackupCodesPage(backupCodes: codes);
            },
          ),
        ],
      ),

      // ── Votación de feria (JURY) ─────────────────────────────────────
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
                path: 'project/:projectId/rubric',
                builder: (_, s) => RubricEvaluationPage(
                  fairId: s.pathParameters['fairId']!,
                  projectId: s.pathParameters['projectId']!,
                ),
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

      // ── Evaluación docente (STUDENT) ───────────────────────────────
      GoRoute(
        path: '/teaching',
        pageBuilder: (_, s) => _tabPage(s, const TeachingHomePage()),
        routes: [
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
    ],
    debugLogDiagnostics: false,
  );
}

/// Destinos de la barra inferior (panel del rol y cuenta).
///
/// Cambiar de pestaña no es avanzar en la navegación: un fundido corto evita
/// el deslizamiento de "pantalla nueva" que hacía sentir cada toque como un
/// salto a otra sección.
Page<void> _tabPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 120),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(WidgetRef ref) {
    ref.listenManual(authControllerProvider, (_, __) => notifyListeners());
    // Refresca el router cuando se dispara un logout forzado (401/refresh).
    ref.listenManual(authEventsProvider, (_, __) => notifyListeners());
  }
}
