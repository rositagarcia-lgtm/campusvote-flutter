import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/splash_page.dart';
import '../../features/auth/domain/entities/auth_role.dart';
import '../../features/auth/presentation/pages/account_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/pages/email_otp_verify_page.dart';
import '../../features/auth/presentation/pages/email_request_page.dart';
import '../../features/auth/presentation/pages/jury_login_page.dart';
import '../../features/auth/presentation/pages/security_page.dart';
import '../../features/auth/presentation/pages/totp_backup_codes_page.dart';
import '../../features/auth/presentation/pages/totp_page.dart';
import '../../features/auth/presentation/pages/totp_setup_page.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../../features/auth/presentation/state/auth_events.dart';
import 'role_landing.dart';
import '../../features/fair_voting/presentation/pages/fair_projects_page.dart';
import '../../features/fair_voting/presentation/pages/my_fairs_page.dart';
import '../../features/fair_voting/presentation/pages/rubric_page.dart';
import '../../features/fair_voting/presentation/pages/voting_page.dart';
import '../../features/fair_voting/presentation/pages/voting_success_page.dart';
import '../../features/teaching_evaluation/presentation/pages/teacher_evaluation_page.dart';
import '../../features/teaching_evaluation/presentation/pages/teacher_evaluation_success_page.dart';
import '../../features/teaching_evaluation/presentation/pages/teaching_home_page.dart';

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
        return '/security/password';
      }
      // Para usuarios autenticados, mandamos a la pantalla principal según
      // su rol. La autoridad es `user.role` del backend, no el panel que el
      // usuario tocó en el splash.
      if (auth.authenticated && publicRoutes.contains(loc)) {
        return landingPathForRole(auth.user?.role);
      }
      // No renderizar un panel ajeno. El backend sigue siendo la autoridad
      // (rechaza las peticiones), pero evita mostrar la UI de otro rol.
      if (auth.authenticated) {
        final opensJuryPanel = loc.startsWith('/juries');
        final opensStudentPanel = loc.startsWith('/teaching');
        final isJury = auth.user?.role == AuthRole.jury;
        if (opensJuryPanel != isJury && (opensJuryPanel || opensStudentPanel)) {
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
      GoRoute(path: '/account', builder: (_, __) => const AccountPage()),
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
      GoRoute(
        path: '/juries',
        redirect: (context, state) {
          return '/juries/fairs';
        },
      ),
      GoRoute(
        path: '/juries/fairs',
        builder: (_, __) => const MyFairsPage(),
        routes: [
          GoRoute(
            path: ':fairId/projects',
            builder: (_, s) => FairProjectsPage(
              fairId: s.pathParameters['fairId']!,
            ),
            routes: [
              GoRoute(
                path: ':projectId/rubric',
                builder: (_, s) => RubricPage(
                  fairId: s.pathParameters['fairId']!,
                  projectId: s.pathParameters['projectId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: ':fairId/voting',
            builder: (_, s) => VotingPage(
              fairId: s.pathParameters['fairId']!,
            ),
            routes: [
              GoRoute(
                path: 'success',
                builder: (_, s) => VotingSuccessPage(
                  fairId: s.pathParameters['fairId']!,
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Evaluación docente (STUDENT) ───────────────────────────────
      GoRoute(
        path: '/teaching',
        builder: (_, __) => const TeachingHomePage(),
        routes: [
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

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(WidgetRef ref) {
    ref.listenManual(authControllerProvider, (_, __) => notifyListeners());
    // Refresca el router cuando se dispara un logout forzado (401/refresh).
    ref.listenManual(authEventsProvider, (_, __) => notifyListeners());
  }
}
