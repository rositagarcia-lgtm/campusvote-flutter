import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/branding/branding_controller.dart';
import '../core/settings/app_preferences.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/widgets/fade_slide.dart';
import '../features/settings/presentation/settings_copy.dart';
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
    final text = SettingsCopy.of(context);
    final language = ref.watch(
      appPreferencesProvider.select((preferences) => preferences.language),
    );
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
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeSlide(child: WelcomeHeader(name: branding.name)),
                      const SizedBox(height: AppSpacing.xxl),
                      FadeSlide(
                        delay: const Duration(milliseconds: 120),
                        child: SectionHeading(
                          overline: text.t('Acceso'),
                          title: text.t('Elige cómo participar'),
                          subtitle:
                              text.t('Selecciona tu perfil para continuar.'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      FadeSlide(
                        delay: const Duration(milliseconds: 220),
                        child: AccessCard(
                          icon: Icons.school_rounded,
                          actionIcon: Icons.mail_outline_rounded,
                          accent: studentColor,
                          title: text.t('Estudiante'),
                          subtitle: text.t(
                              'Evalúa a tus docentes con un código enviado a tu correo. No necesitas contraseña.'),
                          action: text.t('Continuar con mi correo'),
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
                          title: text.t('Jurado'),
                          subtitle: text.t(
                              'Califica proyectos e ingresa con las credenciales enviadas por el administrador.'),
                          action: text.t('Ingresar como jurado'),
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
                                text.t(
                                    'Acceso exclusivo para la comunidad académica'),
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
                  Positioned(
                    top: 0,
                    right: 0,
                    child: PopupMenuButton<AppLanguage>(
                      tooltip: text.languageLabel,
                      icon: Icon(Icons.language_rounded, color: muted),
                      iconSize: AppDimensions.iconMedium,
                      onSelected: (selected) {
                        ref
                            .read(appPreferencesProvider.notifier)
                            .setLanguage(selected);
                      },
                      itemBuilder: (context) => [
                        CheckedPopupMenuItem(
                          value: AppLanguage.spanish,
                          checked: language == AppLanguage.spanish,
                          child: Text(text.spanish),
                        ),
                        CheckedPopupMenuItem(
                          value: AppLanguage.english,
                          checked: language == AppLanguage.english,
                          child: Text(text.english),
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
