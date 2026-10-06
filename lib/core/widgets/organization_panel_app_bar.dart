import 'package:flutter/material.dart';

import '../branding/organization_branding.dart';
import '../theme/app_dimensions.dart';
import 'app_logo.dart';

/// Barra para áreas autenticadas: muestra la organización activa del servidor.
class OrganizationPanelAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const OrganizationPanelAppBar({
    super.key,
    required this.branding,
    required this.section,
    this.actions = const [],
    this.onBack,
  });

  final OrganizationBranding branding;
  final String section;
  final List<Widget> actions;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(69);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = branding.name.trim().isEmpty ? 'Organización' : branding.name;
    return AppBar(
      toolbarHeight: 68,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleSpacing: onBack == null ? AppSpacing.s : 0,
      leadingWidth: 52,
      leading: onBack == null
          ? Padding(
              padding: const EdgeInsets.only(left: AppSpacing.l),
              child: Center(
                child: Semantics(
                  image: true,
                  label: 'Logo de $name',
                  child: AppLogo.organization(
                    logoUrl: branding.logoUrl,
                    organizationCode: name,
                    size: 38,
                  ),
                ),
              ),
            )
          : IconButton(
              tooltip: 'Volver',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
      title: Row(
        children: [
          if (onBack != null) ...[
            AppLogo.organization(
              logoUrl: branding.logoUrl,
              organizationCode: name,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.s),
          ],
          Expanded(child: _IdentityText(name: name, section: section)),
        ],
      ),
      actions: [...actions, const SizedBox(width: AppSpacing.xs)],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colors.primary.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _IdentityText extends StatelessWidget {
  const _IdentityText({required this.name, required this.section});

  final String name;
  final String section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          section,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
