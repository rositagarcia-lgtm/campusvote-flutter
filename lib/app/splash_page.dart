import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/branding/branding_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/widgets/fade_slide.dart';
import 'splash_widgets.dart';

/// Bienvenida y selección del flujo de acceso según el rol.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkInkMuted : AppColors.inkMuted;
    final studentColor = isDark ? AppColors.primaryLighter : AppColors.primary;
    final juryColor = isDark ? AppColors.accentLight : const Color(0xFF80600E);

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
                  FadeSlide(child: WelcomeHeader(name: branding.name)),
                  const SizedBox(height: AppSpacing.xxl),
                  const FadeSlide(
                    delay: Duration(milliseconds: 120),
                    child: SectionHeading(
                      overline: 'Acceso',
                      title: 'Elige cómo participar',
                      subtitle: 'Selecciona tu perfil para continuar.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  FadeSlide(
                    delay: const Duration(milliseconds: 220),
                    child: AccessCard(
                      icon: Icons.school_rounded,
                      actionIcon: Icons.mail_outline_rounded,
                      accent: studentColor,
                      title: 'Estudiante',
                      subtitle:
                          'Evalúa a tus docentes con un código enviado a tu correo. No necesitas contraseña.',
                      action: 'Continuar con mi correo',
                      onTap: () => context.go('/auth/email-request'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  FadeSlide(
                    delay: const Duration(milliseconds: 320),
                    child: AccessCard(
                      icon: Icons.gavel_rounded,
                      actionIcon: Icons.lock_outline_rounded,
                      accent: juryColor,
                      title: 'Jurado',
                      subtitle:
                          'Califica proyectos e ingresa con las credenciales enviadas por el administrador.',
                      action: 'Ingresar como jurado',
                      onTap: () => context.go('/auth/jury/login'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeSlide(
                    delay: const Duration(milliseconds: 420),
                    child: Row(
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
                            'Acceso exclusivo para la comunidad académica',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
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
