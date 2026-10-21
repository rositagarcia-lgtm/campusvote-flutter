part of '../app_router.dart';

List<RouteBase> _authRoutes(WidgetRef ref) => [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),

      // Acceso del jurado con sus credenciales.
      GoRoute(
        path: '/auth/jury/login',
        builder: (_, __) => const JuryLoginPage(),
      ),
      // Acceso del docente mediante código por correo.
      GoRoute(
        path: '/auth/teacher',
        builder: (_, __) => const EmailRequestPage(teacher: true),
      ),
      GoRoute(
        path: '/auth/password/forgot',
        builder: (_, __) => const PasswordResetRequestPage(),
      ),

      // Acceso del estudiante mediante código por correo.
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
              // El cambio forzado sale del estado de sesión. El estudiante
              // entra con código de correo y no queda atrapado en esta pantalla.
              required: s.extra == true ||
                  ref.read(authControllerProvider).forcesPasswordChange,
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
    ];
