import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/branding/branding_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/widgets/app_logo.dart';
import '../core/widgets/fade_slide.dart';

/// Bienvenida y selección del flujo de acceso según el rol.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final studentColor = isDark ? AppColors.primaryLighter : AppColors.primary;
    final juryColor = isDark ? AppColors.accentLight : const Color(0xFF80600E);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlide(
                    child: _WelcomeHeader(name: branding.name),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FadeSlide(
                    delay: const Duration(milliseconds: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Elige cómo participar',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Selecciona tu perfil para continuar.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkInkMuted
                                : AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  FadeSlide(
                    delay: const Duration(milliseconds: 220),
                    child: _AccessCard(
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
                    child: _AccessCard(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkPrimarySoft, AppColors.darkSurface]
              : [AppColors.primarySoft, AppColors.primarySubtle],
        ),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.primarySoft,
        ),
      ),
      child: Column(
        children: [
          // La base blanca mantiene legible el asset transparente en ambos temas.
          Semantics(
            image: true,
            label: 'Logo de CampusVote',
            child: Container(
              width: 116,
              height: 116,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.primarySoft, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: AppLogo.asset(size: 96),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkInk : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Votación y evaluación académica',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkInkMuted : AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({
    required this.icon,
    required this.actionIcon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final IconData actionIcon;
  final Color accent;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tint = accent.withValues(alpha: isDark ? 0.14 : 0.08);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 2,
      shadowColor: accent.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accent.withValues(alpha: 0.32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: tint,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: AppRadii.rLarge,
                    ),
                    child: Icon(icon, color: accent, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: accent, size: 18),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkInkMuted : AppColors.inkMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.m,
                ),
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: AppRadii.rMedium,
                ),
                child: Row(
                  children: [
                    Icon(actionIcon, size: 20, color: accent),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        action,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: accent, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
