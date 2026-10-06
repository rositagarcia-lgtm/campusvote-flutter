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

/// Datos de la cuenta como filas etiqueta-valor separadas por divisores.
class AccountInfoList extends StatelessWidget {
  const AccountInfoList({
    super.key,
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divider = Divider(height: 1, thickness: 1, color: appBorder(isDark));

    return Column(
      children: [
        _InfoRow(
            icon: Icons.badge_outlined,
            label: SettingsCopy.of(context).t('Nombre'),
            value: name),
        divider,
        _InfoRow(
            icon: Icons.mail_outline_rounded,
            label: SettingsCopy.of(context).t('Correo'),
            value: email),
        divider,
        _InfoRow(
            icon: Icons.shield_outlined,
            label: SettingsCopy.of(context).t('Rol'),
            value: role),
      ],
    );
  }
}

/// Fila etiqueta-valor: la etiqueta en tono secundario y el dato en primer
/// plano, alineado a la derecha para que la columna de valores sea legible.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = appMuted(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppDimensions.iconMedium, color: muted),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
