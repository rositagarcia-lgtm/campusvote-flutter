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
import '../../features/fair_audience/presentation/audience_projects_page.dart';
import '../../features/fair_audience/presentation/explore_fairs_page.dart';
import '../../features/fair_audience/presentation/scan_stand_page.dart';
import '../../features/certificates/presentation/my_certificates_page.dart';
import '../../features/fair_results/presentation/published_results_page.dart';
import '../../features/teacher_results/presentation/adviser_project_detail_page.dart';
import '../../features/teacher_results/presentation/adviser_projects_page.dart';
import '../../features/teacher_results/presentation/teacher_home_page.dart';
import '../../features/teacher_results/presentation/teacher_results_page.dart';
import '../../features/teaching_evaluation/presentation/pages/teaching_home_page.dart';
import '../../features/jury/presentation/pages/jury_invitation_page.dart';
import '../../features/jury/presentation/pages/jury_project_detail_page.dart';
import 'deep_links.dart';
import 'legacy_jury_routes.dart';
import 'role_landing.dart';
import '../config/constants.dart';
part 'routes/auth_routes.dart';
part 'routes/fair_routes.dart';
part 'routes/jury_routes.dart';
part 'routes/student_routes.dart';
part 'routes/teacher_routes.dart';

/// Router global.
///
/// Implementa guards:
/// - authenticated
/// - contraseña temporal del jurado → forzado a /security/password
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

      // Enlace de la web (QR del stand, invitación): si aún no se puede abrir
      // (arranque o sin sesión), se guarda para retomarlo después.
      final opensInvitation = loc.startsWith('/j/');
      if (isAppLink(loc) &&
          (auth.initializing || (!auth.authenticated && !opensInvitation))) {
        PendingDeepLink.remember(state.uri.toString());
      }

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
        '/auth/teacher',
        '/auth/email-request',
        '/auth/email-verify',
        '/auth/password/forgot',
        '/auth/totp',
      };
      // La invitación de jurado se puede abrir sin sesión: crea la cuenta.
      if (!auth.authenticated && opensInvitation) return null;
      if (!auth.authenticated &&
          loc == '/splash' &&
          PendingDeepLink.hasInvitation) {
        return PendingDeepLink.take();
      }
      if (!auth.authenticated && !publicRoutes.contains(loc)) {
        return '/splash';
      }
      // Forzar cambio de contraseña obligatorio antes de cualquier otra ruta
      // (incluido el salto al panel de su rol).
      if (auth.authenticated &&
          auth.forcesPasswordChange &&
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
        if (loc == '/splash' &&
            !SplashPage.introCompleted &&
            !PendingDeepLink.hasAny) {
          return null;
        }
        // Tras iniciar sesión se retoma el enlace que abrió la app.
        final pending = PendingDeepLink.take();
        if (pending != null) return pending;
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
        // Panel docente: solo el rol TEACHER.
        final segments = Uri.parse(loc).pathSegments;
        if (segments.isNotEmpty &&
            segments.first == 'teacher' &&
            auth.user?.role != AuthRole.teacher) {
          return landingPathForRole(auth.user?.role);
        }
      }
      return null;
    },
    routes: [
      ..._authRoutes(ref),
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsPage()),
      ..._fairRoutes(ref),
      ..._teacherRoutes(ref),
      ..._juryRoutes(ref),
      ..._studentRoutes(ref),
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
