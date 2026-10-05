import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/branding/branding_controller.dart';
import '../core/theme/app_dimensions.dart';
import 'splash_intro_video.dart';
import 'splash_widgets.dart';

/// Bienvenida y selección del flujo de acceso según el rol.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  static bool _introCompleted = false;
  bool _showWelcome = _introCompleted;

  void _showWelcomePage() {
    if (mounted && !_showWelcome) {
      _introCompleted = true;
      setState(() => _showWelcome = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showWelcome) {
      return SplashIntroVideo(onFinished: _showWelcomePage);
    }

    final branding = ref.watch(brandingControllerProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final studentColor = theme.colorScheme.primary;
    final juryColor = theme.colorScheme.secondary;

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
                  WelcomeHeader(name: branding.name),
                  const SizedBox(height: AppSpacing.xxl),
                  const SectionHeading(
                    overline: 'BIENVENIDO',
                    title: 'Elige cómo participar',
                    subtitle: 'Cada perfil tiene un acceso propio.',
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AccessCard(
                    icon: Icons.school_outlined,
                    actionIcon: Icons.mail_outline_rounded,
                    accent: studentColor,
                    title: 'Estudiante',
                    subtitle:
                        'Evalúa a tus docentes con un código enviado a tu correo institucional.',
                    action: 'Continuar con mi correo',
                    onTap: () => context.go('/auth/email-request'),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AccessCard(
                    icon: Icons.gavel_outlined,
                    actionIcon: Icons.lock_outline_rounded,
                    accent: juryColor,
                    title: 'Jurado',
                    subtitle:
                        'Revisa proyectos y vota con las credenciales que recibiste.',
                    action: 'Ingresar como jurado',
                    onTap: () => context.go('/auth/jury/login'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: AppDimensions.iconSmall,
                        color: muted,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Flexible(
                        child: Text(
                          'Acceso para la comunidad académica',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                    ],
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
