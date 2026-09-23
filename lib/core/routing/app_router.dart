import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/splash_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
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
import '../../features/voting/presentation/pages/ballot_page.dart';
import '../../features/voting/presentation/pages/election_detail_page.dart';
import '../../features/voting/presentation/pages/vote_confirmation_page.dart';
import '../../features/voting/presentation/pages/vote_success_page.dart';
import '../../features/voting/presentation/pages/voting_home_page.dart';
import '../../features/voting/presentation/pages/voting_receipt_page.dart';

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
      // '/splash' NO va en esta lista: mientras se comprueba la sesión ya se
      // devolvió arriba. Si estuviera aquí, quien no tiene sesión se quedaría
      // en la pantalla de carga para siempre en vez de pasar al login.
      final publicRoutes = {
        '/login',
        '/auth/totp',
      };
      if (!auth.authenticated && !publicRoutes.contains(loc)) {
        return '/login';
      }
      // Para usuarios autenticados, mandamos a la pantalla principal.
      // El backend determina qué vista le corresponde (JURY → /juries/fairs;
      // otros roles → /voting) pero como Flutter no filtra por rol, lo dejamos
      // al controller/redirección del cliente según `auth.user.role`.
      if (auth.authenticated && (loc == '/login' || loc == '/splash')) {
        final role = auth.user?.role;
        if (role == 'JURY') return '/juries/fairs';
        return '/voting';
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
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
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

      // ── Votación electoral (existente) ──────────────────────────────
      GoRoute(
        path: '/voting',
        builder: (_, __) => const VotingHomePage(),
        routes: [
          GoRoute(
            path: ':electionId',
            builder: (_, s) => ElectionDetailPage(
              electionId: s.pathParameters['electionId']!,
            ),
            routes: [
              GoRoute(
                path: 'ballot',
                builder: (_, s) => BallotPage(
                  electionId: s.pathParameters['electionId']!,
                ),
              ),
              GoRoute(
                path: 'confirmation',
                builder: (_, s) => VoteConfirmationPage(
                  electionId: s.pathParameters['electionId']!,
                ),
              ),
              GoRoute(
                path: 'success',
                builder: (_, s) => VoteSuccessPage(
                  electionId: s.pathParameters['electionId']!,
                ),
              ),
              GoRoute(
                path: 'receipt/:receiptCode',
                builder: (_, s) => VotingReceiptPage(
                  electionId: s.pathParameters['electionId']!,
                  receiptCode: s.pathParameters['receiptCode']!,
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