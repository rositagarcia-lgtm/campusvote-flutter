import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/branding/branding_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/brand_colors.dart';
import '../core/widgets/app_logo.dart';

/// Bienvenida con la marca de la organización (o la neutral de CampusVote).
///
/// Dos accesos diferenciados y visualmente distintos:
///  - **Panel del estudiante** → evalúa a sus docentes.
///  - **Panel del jurado** → califica proyectos de ferias.
/// Ambos entran con correo + código; el backend resuelve la organización y el
/// rol a partir del correo.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingControllerProvider);
    final theme = Theme.of(context);
    final primary = context.brandPrimary;
    final secondary = context.brandSecondary;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo suave con tinte de la marca.
          Positioned(
            top: -140,
            right: -120,
            child: _orb(primary.withValues(alpha: isDark ? 0.18 : 0.14), 320),
          ),
          Positioned(
            top: 180,
            left: -90,
            child: _orb(secondary.withValues(alpha: isDark ? 0.10 : 0.10), 220),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Hero de marca: logo (asset) + identidad ───────────
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.rXLarge,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primary,
                          Color.lerp(primary, Colors.black, 0.18)!,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          top: -30,
                          child: _orb(
                            Colors.white.withValues(alpha: 0.10),
                            150,
                          ),
                        ),
                        Positioned(
                          right: 40,
                          bottom: -40,
                          child: _orb(
                            Colors.white.withValues(alpha: 0.08),
                            130,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            children: [
                              Container(
                                width: 92,
                                height: 92,
                                padding: const EdgeInsets.all(AppSpacing.m),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppRadii.rXLarge,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.16),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                // Logo de la organización (URL) cuando el
                                // backend ya la resolvió; si no, el logo de
                                // producto de CampusVote.
                                child: branding.logoUrl != null &&
                                        branding.logoUrl!.isNotEmpty
                                    ? Image.network(
                                        branding.logoUrl!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            Image.asset(
                                          kCampusVoteLogoAsset,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : Image.asset(
                                        kCampusVoteLogoAsset,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                              const SizedBox(height: AppSpacing.l),
                              Text(
                                branding.name,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.m,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: AppRadii.rMedium,
                                ),
                                child: Text(
                                  'Votación y rendición académica',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    '¿Qué panel quieres abrir?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Elige tu perfil. Ambos usan tu correo y un código seguro.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // ── Panel del estudiante ──────────────────────────────
                  _AccessCard(
                    icon: Icons.school_rounded,
                    accent: primary,
                    title: 'Panel del estudiante',
                    subtitle: 'Evalúa a tus docentes por curso y ciclo',
                    tags: const ['Docentes', 'Periodo actual'],
                    backgroundColor: cardBg,
                    onTap: () => context.go('/auth/email-request'),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // ── Panel del jurado ──────────────────────────────────
                  _AccessCard(
                    icon: Icons.gavel_rounded,
                    accent: secondary,
                    title: 'Panel del jurado',
                    subtitle: 'Califica proyectos y vota en las ferias',
                    tags: const ['Rúbrica', 'Votación final'],
                    backgroundColor: cardBg,
                    onTap: () => context.go('/auth/email-request'),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: AppDimensions.iconMedium,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Flexible(
                        child: Text(
                          'Acceso sin contraseñas · código por correo',
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _AccessCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final List<String> tags;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _AccessCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.rXLarge,
        side: BorderSide(color: accent.withValues(alpha: 0.35), width: 1.2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.rXLarge,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
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
                          Color.lerp(accent, Colors.black, 0.15)!,
                        ],
                      ),
                      borderRadius: AppRadii.rLarge,
                    ),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: accent,
                    size: 26,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  for (final tag in tags) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s * 1.5,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? accent.withValues(alpha: 0.16)
                            : accent.withValues(alpha: 0.10),
                        borderRadius: AppRadii.rSmall,
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (tag != tags.last) const SizedBox(width: AppSpacing.s),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}