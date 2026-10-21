import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/app_logo.dart';
import '../../features/settings/presentation/settings_copy.dart';

/// Cabecera institucional de la bienvenida: logo, nombre y un hueco a la
/// derecha para el selector de idioma.
///
/// Antes de iniciar sesión el usuario entra a CampusVote, no a su
/// organización; por eso aquí no se usa la marca del tenant.
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = SettingsCopy.of(context);
    return Row(
      children: [
        Semantics(
          image: true,
          label: 'Logo de CampusVote',
          child: AppLogo.asset(size: 44),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CampusVote',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                text.t('Plataforma académica'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
