// settings_organization_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_logo.dart';
import '../settings_copy.dart';

/// Cabecera de Configuración: identidad de la organización y versión de la app.
///
/// El nombre y el logo salen del branding que el backend ya resolvió (mismo
/// proveedor que las barras de los paneles), y la versión se declara una sola
/// vez en `pubspec.yaml`. No hay texto fijo que pueda quedar viejo.
class SettingsOrganizationHeader extends ConsumerWidget {
  const SettingsOrganizationHeader({super.key});

  /// Lado del logo: presence el mosaico de las filas sin competir con ellas.
  static const double _logoExtent = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingControllerProvider);
    final theme = Theme.of(context);
    final text = SettingsCopy.of(context);

    final name = branding.name.trim();
    final organization =
        name.isEmpty ? AppConstants.appName : name;

    return AppCard(
      child: Row(
        children: [
          Semantics(
            image: true,
            label: text.logoLabel(organization),
            // Sin `container` la etiqueta se fusiona con el nodo del hijo (la
            // inicial o el bitmap) y el lector de pantalla anuncia otra cosa.
            container: true,
            excludeSemantics: true,
            child: AppLogo.organization(
              logoUrl: branding.logoUrl,
              organizationCode: organization,
              size: _logoExtent,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  organization.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  text.preferencesTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          const _VersionBadge(label: AppConstants.appVersionLabel),
        ],
      ),
    );
  }
}

/// Píldora de versión: acento primario, sin robar atención al contenido.
class _VersionBadge extends StatelessWidget {
  const _VersionBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: isDark ? 0.20 : 0.10),
        borderRadius: AppRadii.rMedium,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}