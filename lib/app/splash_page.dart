import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/branding/branding_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/widgets/app_logo.dart';
import '../core/widgets/fade_slide.dart';

/// Pantalla de bienvenida: punto de entrada único de la app.
///
/// No es un splash de carga (el bloqueo de arranque vive en
/// `AuthState.initializing` + el redirect del router), sino el selector de
/// acceso. Cada panel abre un flujo DISTINTO:
///
/// - Estudiante → solicita un código de un solo uso por correo (sin
///   contraseña).
/// - Jurado → correo + contraseña, credencial que el administrador le envía
///   por correo.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
            top: AppSpacing.xl,
            bottom: AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LOGO DE CAMPUSVOTE: identidad de la app, no de la
              // organización, por eso es un asset local y no branding.logoUrl.
              FadeSlide(
                delay: Duration.zero,
                offset: 30,
                child: Center(
                  child: AppLogo.asset(size: 110),
                ),
              ),

              const SizedBox(height: AppSpacing.l),

              FadeSlide(
                delay: const Duration(milliseconds: 150),
                offset: 20,
                child: Text(
                  branding.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s),

              FadeSlide(
                delay: const Duration(milliseconds: 250),
                offset: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: AppRadii.rMedium,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.20),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      'Votación y rendición académica',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              FadeSlide(
                delay: const Duration(milliseconds: 350),
                offset: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Qué panel quieres abrir?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Elige tu perfil. Cada panel entra a su manera.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.l),

              // ── ESTUDIANTE: código por correo (verde CampusVote) ──────────
              FadeSlide(
                delay: const Duration(milliseconds: 450),
                offset: 30,
                child: _AccessCard(
                  icon: Icons.school_rounded,
                  accent: AppColors.primary,
                  title: 'Panel del estudiante',
                  subtitle:
                      'Te enviamos un código a tu correo. Sin contraseña.',
                  tags: const ['Docentes', 'Código por correo'],
                  backgroundColor: cardBg,
                  onTap: () => context.go('/auth/email-request'),
                ),
              ),

              const SizedBox(height: AppSpacing.m),

              // ── JURADO: correo + contraseña (dorado CampusVote) ───────────
              FadeSlide(
                delay: const Duration(milliseconds: 550),
                offset: 30,
                child: _AccessCard(
                  icon: Icons.gavel_rounded,
                  accent: AppColors.accent,
                  title: 'Panel del jurado',
                  subtitle:
                      'Correo y contraseña que te envió el administrador, más un código de seguridad.',
                  tags: const ['Rúbrica', 'Votación final'],
                  backgroundColor: cardBg,
                  onTap: () => context.go('/auth/jury/login'),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final List<String> tags;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.rXLarge,
        side: BorderSide(color: accent.withValues(alpha: 0.30), width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: accent.withValues(alpha: 0.04),
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent,
                          Color.lerp(accent, Colors.black, 0.15)!
                        ],
                      ),
                      borderRadius: AppRadii.rLarge,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.75),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: accent, size: 24),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final tag in tags)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? accent.withValues(alpha: 0.15)
                            : accent.withValues(alpha: 0.08),
                        borderRadius: AppRadii.rSmall,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
