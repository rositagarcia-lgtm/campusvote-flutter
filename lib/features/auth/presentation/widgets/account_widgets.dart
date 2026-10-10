import 'package:flutter/material.dart';

import '../../../../core/branding/organization_branding.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../settings/presentation/settings_copy.dart';

/// Bloque de "Sobre mí": sobretítulo de sección y tarjeta plana con borde fino.
///
/// Reusa `SectionHeader` y la misma tarjeta plana con borde que el resto de
/// paneles, para que la jerarquía no cambie de pantalla.
class AccountSection extends StatelessWidget {
  const AccountSection({
    super.key,
    required this.overline,
    required this.child,
    this.count,
  });

  final String overline;
  final Widget child;

  /// Número de filas del bloque; se muestra en la píldora del encabezado.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(label: overline, count: count),
        Material(
          color: theme.colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.rLarge,
            side: BorderSide(color: appBorder(isDark)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: child,
          ),
        ),
      ],
    );
  }
}

/// Logo y nombre de la organización a la que pertenece la cuenta.
class AccountOrganizationRow extends StatelessWidget {
  const AccountOrganizationRow({super.key, required this.branding});

  final OrganizationBranding branding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        AppLogo.organization(
          logoUrl: branding.logoUrl,
          organizationCode: branding.name,
          size: AppDimensions.touchTarget,
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                branding.name,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                SettingsCopy.of(context).t('Organización de tu cuenta'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: appMuted(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
