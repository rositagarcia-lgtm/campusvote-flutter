import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_motion.dart';

/// Fila de un grupo de ajustes: ícono en mosaico, título, descripción y un
/// elemento opcional a la derecha (estado, contador).
class AccountSettingsItem {
  const AccountSettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
}

/// Lista agrupada en una sola tarjeta, al estilo de los ajustes del sistema:
/// todo lo configurable de la cuenta en un mismo lugar.
class AccountSettingsGroup extends StatelessWidget {
  const AccountSettingsGroup({super.key, required this.items});

  final List<AccountSettingsItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: AppSpacing.l + 40 + AppSpacing.m,
                color: scheme.outlineVariant,
              ),
            _Row(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item});

  final AccountSettingsItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    scheme.primary.withValues(alpha: 0.10),
                    scheme.surface,
                  ),
                  borderRadius: AppRadii.rMedium,
                ),
                child: Icon(item.icon, size: 20, color: scheme.primary),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(item.subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (item.trailing != null) ...[
                const SizedBox(width: AppSpacing.s),
                item.trailing!,
              ],
              const SizedBox(width: AppSpacing.xs),
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Punto de estado con etiqueta corta (p. ej. "Protegida").
class AccountStatusPill extends StatelessWidget {
  const AccountStatusPill(
      {super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.medium,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
