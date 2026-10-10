import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/config/app_env.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/brand_colors.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_palette.dart';
import '../../../../settings/presentation/settings_copy.dart';

/// Cabecera tipo "carnet": avatar, nombre, correo, rol y acción de foto.
///
/// Tarjeta plana con borde fino: el bloque de identidad ya tiene su propio
/// acento (el avatar), así que no necesita el filete superior de los flujos de
/// acceso.
class AccountIdentityHeader extends StatelessWidget {
  const AccountIdentityHeader({
    super.key,
    required this.accent,
    required this.avatarUrl,
    required this.displayName,
    required this.email,
    required this.roleLabel,
    required this.uploading,
    required this.onPickPhoto,
  });

  final Color accent;
  final String? avatarUrl;
  final String displayName;
  final String email;
  final String roleLabel;
  final bool uploading;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Carnet institucional: franja con el color de la organización y el
    // avatar montado encima.
    return AppCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 72,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.large),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: context.brandGradient),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomRight,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 4,
                        ),
                      ),
                      child: AccountAvatar(
                        avatarUrl: avatarUrl,
                        displayName: displayName,
                        accent: accent,
                        size: 96,
                      ),
                    ),
                    if (uploading)
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black38,
                          ),
                          child: Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),
                    Positioned(
                      right: -AppSpacing.xs,
                      bottom: -AppSpacing.xs,
                      child: Semantics(
                        button: true,
                        label: SettingsCopy.of(context)
                            .t('Cambiar foto de perfil'),
                        excludeSemantics: true,
                        child: Material(
                          color: accent,
                          shape: CircleBorder(
                            side: BorderSide(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: uploading ? null : onPickPhoto,
                            child: const SizedBox(
                              width: AppDimensions.touchTarget,
                              height: AppDimensions.touchTarget,
                              child: Icon(
                                PhosphorIconsRegular.camera,
                                size: AppDimensions.iconMedium,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                Semantics(
                  header: true,
                  child: Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: appMuted(isDark)),
                ),
                const SizedBox(height: AppSpacing.m),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.16 : 0.08),
                    borderRadius: AppRadii.rSmall,
                  ),
                  child: Semantics(
                    label: '${SettingsCopy.of(context).t('Rol')}: $roleLabel',
                    excludeSemantics: true,
                    child: Text(
                      roleLabel.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar circular: foto de red o inicial sobre color plano como respaldo.
///
/// El respaldo nunca es un hueco: si la foto no llega o falla, se muestra la
/// inicial sobre el acento de la cuenta.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    required this.avatarUrl,
    required this.displayName,
    required this.accent,
    this.size = 96,
  });

  final String? avatarUrl;
  final String displayName;
  final Color accent;

  /// Diámetro del avatar.
  final double size;

  @override
  Widget build(BuildContext context) {
    final name = displayName.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );

    final url = AppEnv.mediaUrl(avatarUrl);
    if (url == null) return fallback;
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}
