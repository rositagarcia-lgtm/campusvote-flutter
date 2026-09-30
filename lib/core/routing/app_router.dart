import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/splash_page.dart';
import '../../features/auth/presentation/pages/account_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/pages/email_otp_verify_page.dart';
import '../../features/auth/presentation/pages/email_request_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/security_page.dart';
import '../../features/auth/presentation/pages/totp_backup_codes_page.dart';
import '../../features/auth/presentation/pages/totp_page.dart';
import '../../features/auth/presentation/pages/totp_setup_page.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../../features/auth/presentation/state/auth_events.dart';
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
GoRouter buildAppRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshNotifier(ref),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      if (auth.initializing) {
        return loc == '/splash' ? null : '/splash';
      }
      // '/splash' (bienvenida) es pública: quien no tiene sesión la ve.
      final publicRoutes = {
        '/splash',
        '/login',
        '/auth/totp',
        '/auth/email-request',
        '/auth/email-verify',
      };
      if (!auth.authenticated && !publicRoutes.contains(loc)) {
        return '/splash';
      }
      // Para usuarios autenticados, mandamos a la pantalla principal según
      // su rol: JURY evalúa ferias, STUDENT evalúa docentes, y los demás roles
      // (ADMIN/TEACHER) caen en la vista de docentes (sin asignaciones si no
      // corresponden) o en un inicio genérico.
      if (auth.authenticated &&
          (loc == '/login' ||
              loc == '/splash' ||
              loc == '/auth/email-request' ||
              loc == '/auth/email-verify')) {
        final role = auth.user?.role;
        if (role == 'JURY') return '/juries/fairs';
        return '/teaching';
      }
      // Forzar cambio de contraseña obligatorio antes de cualquier otra ruta.
      if (auth.authenticated &&
          auth.mustChangePassword &&
          loc != '/security/password') {
        return '/security/password';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(
        path: '/auth/email-request',
        builder: (_, __) => const EmailRequestPage(),
      ),
      GoRoute(
        path: '/auth/email-verify',
        builder: (_, __) => const EmailOtpVerifyPage(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/account', builder: (_, __) => const AccountPage()),
      GoRoute(path: '/auth/totp', builder: (_, __) => const TotpPage()),
      GoRoute(
        path: '/security',
        builder: (_, __) => const SecurityPage(),
        routes: [
          GoRoute(
            path: 'password',
            builder: (_, s) => ChangePasswordPage(
              required: s.extra == true || _isRequired(s),
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

bool _isRequired(GoRouterState s) => false;

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(WidgetRef ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
    // Refresca el router cuando se dispara un logout forzado (401/refresh).
    ref.listen(authEventsProvider, (_, __) => notifyListeners());
  }
}