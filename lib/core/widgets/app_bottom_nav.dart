import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_role.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../theme/app_dimensions.dart';
import 'app_palette.dart';

/// Navegación estable para el panel del rol y el perfil.
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isJury = ref.watch(
      authControllerProvider.select((s) => s.user?.role == AuthRole.jury),
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final muted = appMuted(isDark);

    final items = [
      _NavItem(
        icon: isJury ? Icons.gavel_outlined : Icons.school_outlined,
        selectedIcon: isJury ? Icons.gavel_rounded : Icons.school_rounded,
        label: 'Mi panel',
      ),
      const _NavItem(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: 'Sobre mí',
      ),
    ];

    void onSelect(int index) {
      if (index == selectedIndex) return;
      HapticFeedback.selectionClick();
      context.go(index == 0 ? (isJury ? '/jury' : '/teaching') : '/account');
    }

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 72,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(top: BorderSide(color: appBorder(isDark))),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavButton(
                          item: items[i],
                          selected: i == selectedIndex,
                          accent: accent,
                          muted: muted,
                          onTap: () => onSelect(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.accent,
    required this.muted,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final Color accent;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? accent : muted;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Tooltip(
        message: item.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadii.rMedium,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: AppDimensions.touchTarget,
                    height: 2,
                    color: selected ? accent : Colors.transparent,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Icon(
                    selected ? item.selectedIcon : item.icon,
                    size: AppDimensions.iconMedium,
                    color: color,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
