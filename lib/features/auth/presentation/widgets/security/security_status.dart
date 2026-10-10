import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/widgets/app_motion.dart';
import '../../../../settings/presentation/settings_copy.dart';

/// Nivel de protección de la cuenta según los factores activos.
///
/// Hoy el único factor opcional es la verificación en dos pasos; el nivel se
/// calcula aquí para que la cuenta y la pantalla de seguridad digan lo mismo.
enum SecurityLevel {
  loading,
  basic,
  strong;

  static SecurityLevel of({required bool loading, required bool twoFactor}) {
    if (loading) return SecurityLevel.loading;
    return twoFactor ? SecurityLevel.strong : SecurityLevel.basic;
  }

  String get label => switch (this) {
        SecurityLevel.loading => 'Verificando',
        SecurityLevel.basic => 'Protección básica',
        SecurityLevel.strong => 'Cuenta protegida',
      };

  String get hint => switch (this) {
        SecurityLevel.loading => 'Consultando el estado de tu cuenta',
        SecurityLevel.basic =>
          'Activa la verificación en dos pasos para proteger tu acceso',
        SecurityLevel.strong =>
          'Contraseña y verificación en dos pasos activas',
      };

  Color get color => switch (this) {
        SecurityLevel.loading => AppColors.inkFaint,
        SecurityLevel.basic => AppColors.warning,
        SecurityLevel.strong => AppColors.success,
      };

  IconData get icon => switch (this) {
        SecurityLevel.loading => PhosphorIconsRegular.shield,
        SecurityLevel.basic => PhosphorIconsRegular.shield,
        SecurityLevel.strong => PhosphorIconsFill.shieldCheck,
      };

  /// Pasos cumplidos de dos (contraseña siempre; 2FA opcional).
  int get steps => this == SecurityLevel.strong ? 2 : 1;
}

/// Cabecera de la pantalla de seguridad: escudo con el nivel y una barra de
/// dos tramos (contraseña · verificación en dos pasos) que se llena.
class SecurityStatusBanner extends StatelessWidget {
  const SecurityStatusBanner({super.key, required this.level});

  final SecurityLevel level;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = level.color;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.08), scheme.surface),
        borderRadius: AppRadii.rXLarge,
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                key: ValueKey(level),
                tween:
                    Tween(begin: AppMotion.reduced(context) ? 1 : 0.6, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, s, child) =>
                    Transform.scale(scale: s, child: child),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(level.icon, color: color, size: 28),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        text.t(level.label),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(text.t(level.hint), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      end: level != SecurityLevel.loading && i < level.steps
                          ? 1
                          : 0,
                    ),
                    duration: AppMotion.slow,
                    curve: AppMotion.emphasized,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      color: color,
                      backgroundColor: scheme.outlineVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Expanded(
                child: Text(text.t('Contraseña'),
                    style: theme.textTheme.labelSmall),
              ),
              Expanded(
                child: Text(text.t('Verificación en dos pasos'),
                    style: theme.textTheme.labelSmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
