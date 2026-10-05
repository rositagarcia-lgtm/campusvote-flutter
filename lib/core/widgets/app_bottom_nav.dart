import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_role.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../../features/settings/presentation/settings_copy.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Barra de navegación inferior flotante compartida por los paneles.
///
/// - destino 0: el panel del rol (jurado → ferias, resto → docentes).
/// - destino 1: "Sobre mí" (perfil, foto, seguridad, salir).
///
/// La pestaña activa se expande en una píldora con ícono y etiqueta; las
/// demás muestran solo el ícono (con etiqueta accesible y tooltip).
class AppBottomNav extends ConsumerWidget {
  final int selectedIndex;

  const AppBottomNav({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isJury = ref.watch(
      authControllerProvider.select((s) => s.user?.role == AuthRole.jury),
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final text = SettingsCopy.of(context);
    final border = isDark ? AppColors.darkBorder : AppColors.primarySoft;

    final items = [
      _NavItem(
        icon: isJury ? Icons.gavel_outlined : Icons.school_outlined,
        selectedIcon: isJury ? Icons.gavel_rounded : Icons.school_rounded,
        label: text.t('Mi panel'),
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: text.t('Sobre mí'),
      ),
    ];

    void onSelect(int i) {
      if (i == selectedIndex) return;
      HapticFeedback.selectionClick();
      if (i == 0) {
        context.go(isJury ? '/jury' : '/teaching');
      } else {
        context.go('/account');
      }
    }

    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.xs,
              AppSpacing.l,
              AppSpacing.s,
            ),
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < items.length; i++)
                  _NavButton(
                    item: items[i],
                    selected: i == selectedIndex,
                    accent: accent,
                    onTap: () => onSelect(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkInkMuted : AppColors.inkMuted;
    final color = selected ? accent : muted;
    const duration = Duration(milliseconds: 260);

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
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              height: AppDimensions.touchTarget,
              constraints: const BoxConstraints(
                minWidth: AppDimensions.touchTarget,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: selected ? AppSpacing.l : AppSpacing.m,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: isDark ? 0.22 : 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? item.selectedIcon : item.icon,
                    size: AppDimensions.iconLarge,
                    color: color,
                  ),
                  AnimatedSize(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.centerLeft,
                    child: selected
                        ? Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.s),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              softWrap: false,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
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
