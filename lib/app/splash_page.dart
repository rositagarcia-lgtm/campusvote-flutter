import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_icons.dart';
import '../core/routing/role_landing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../features/auth/presentation/state/auth_controller.dart';
import '../features/settings/presentation/settings_copy.dart';
import '../core/widgets/app_motion.dart';
import 'splash_intro_video.dart';
import 'splash_widgets.dart';
import 'welcome_language_selector.dart';

/// Bienvenida y selección del flujo de acceso según el rol.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  static bool get introCompleted => _SplashPageState._introCompleted;

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  static bool _introCompleted = false;
  bool _showWelcome = _introCompleted;

  void _showWelcomePage() {
    if (mounted && !_showWelcome) {
      _introCompleted = true;
      final auth = ref.read(authControllerProvider);
      if (!auth.initializing && auth.authenticated) {
        final destination = auth.mustChangePassword
            ? '/security/password'
            : landingPathForRole(auth.user?.role);
        debugPrint('[SplashIntro ${DateTime.now().toIso8601String()}] '
            'navigation.authenticated destination=$destination');
        context.go(destination);
        return;
      }
      debugPrint('[SplashIntro ${DateTime.now().toIso8601String()}] '
          'navigation.welcome authInitializing=${auth.initializing}');
      setState(() => _showWelcome = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showWelcome) {
      return SplashIntroVideo(onFinished: _showWelcomePage);
    }

    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final studentColor = AppColors.studentAccess;
    final juryColor = AppColors.juryAccess;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.xl,
            AppSpacing.l,
            AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppMotion.reveal(
                    0,
                    const WelcomeHeader(trailing: WelcomeLanguageSelector()),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: AppSpacing.xl),
                  AppMotion.reveal(
                    1,
                    SectionHeading(
                      overline: text.t('Acceso institucional'),
                      title: text.t('Elige cómo participar'),
                      subtitle: text.t(
                        'Selecciona tu opción para continuar de forma segura.',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppMotion.reveal(
                    2,
                    AccessCard(
                      icon: PhosphorIconsRegular.graduationCap,
                      actionIcon: PhosphorIconsRegular.envelopeSimple,
                      accent: studentColor,
                      eyebrow: text.t('ESTUDIANTES Y JURADOS INTERNOS'),
                      title: text.t('Acceso por correo'),
                      subtitle: text.t(
                          'Estudiantes y docentes asignados como jurados reciben un código en su correo institucional. Selecciona este acceso si esa es tu participación.'),
                      action: text.t('Continuar con mi correo'),
                      onTap: () => context.go('/auth/email-request'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppMotion.reveal(
                    3,
                    AccessCard(
                      icon: PhosphorIconsRegular.gavel,
                      actionIcon: PhosphorIconsRegular.lockSimple,
                      accent: juryColor,
                      accentForeground: AppColors.juryAccessInk,
                      eyebrow: text.t('ACCESO DE JURADO'),
                      title: text.t('Jurado calificador'),
                      subtitle: text.t(
                          'Ingresa con las credenciales de jurado que te facilitó la organización. Si no las tienes, consulta al comité organizador.'),
                      action: text.t('Ingresar como jurado'),
                      onTap: () => context.go('/auth/jury/login'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppMotion.reveal(
                    4,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          PhosphorIconsRegular.shieldCheck,
                          size: AppDimensions.iconMedium,
                          color: muted,
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Text(
                            text.t(
                                'Usa el correo y las credenciales asignadas a tu participación.'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
