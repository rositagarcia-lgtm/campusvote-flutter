import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/app_preferences.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/widgets/app_button.dart';
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

    final text = SettingsCopy.of(context);
    final language = ref.watch(
      appPreferencesProvider.select((preferences) => preferences.language),
    );
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<AppLanguage>(
                      tooltip: text.languageLabel,
                      icon: Icon(Icons.language_rounded, color: muted),
                      iconSize: AppDimensions.iconMedium,
                      onSelected: (selected) => ref
                          .read(appPreferencesProvider.notifier)
                          .setLanguage(selected),
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
                  const WelcomeHeader(),
                  const SizedBox(height: AppSpacing.xxl),
                  SectionHeading(
                    overline: text.t('Acceso institucional'),
                    title: text.t('Elige cómo participar'),
                    subtitle: text.t(
                      'Selecciona tu opción para continuar de forma segura.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AccessCard(
                    icon: Icons.school_outlined,
                    actionIcon: Icons.mail_outline_rounded,
                    accent: studentColor,
                    eyebrow: text.t('ESTUDIANTES Y JURADOS INTERNOS'),
                    title: text.t('Acceso por correo'),
                    subtitle: text.t(
                        'Estudiantes y docentes asignados como jurados reciben un código en su correo institucional. Selecciona este acceso si esa es tu participación.'),
                    action: text.t('Continuar con mi correo'),
                    onTap: () => context.go('/auth/email-request'),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AccessCard(
                    icon: Icons.gavel_outlined,
                    actionIcon: Icons.lock_outline_rounded,
                    accent: juryColor,
                    accentForeground: AppColors.juryAccessInk,
                    actionVariant: AppButtonVariant.secondary,
                    eyebrow: text.t('ACCESO DE JURADO'),
                    title: text.t('Jurado calificador'),
                    subtitle: text.t(
                        'Ingresa con las credenciales de jurado que te facilitó la organización. Si no las tienes, consulta al comité organizador.'),
                    action: text.t('Ingresar como jurado'),
                    onTap: () => context.go('/auth/jury/login'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        studentColor.withValues(alpha: 0.06),
                        theme.colorScheme.surface,
                      ),
                      borderRadius: AppRadii.rLarge,
                      border: Border.all(
                        color: studentColor.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: AppDimensions.iconMedium,
                          color: studentColor,
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Text(
                            text.t(
                                'Usa el correo y las credenciales asignadas a tu participaci\u00f3n.'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: muted,
                              height: 1.35,
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
