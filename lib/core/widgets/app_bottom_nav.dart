import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_icons.dart';
import '../../features/auth/domain/entities/auth_role.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../../features/settings/presentation/settings_copy.dart';
import '../../features/student_projects/data/student_projects_repository.dart';
import '../theme/app_dimensions.dart';

/// Destinos de la barra inferior. Cada panel declara el suyo; la barra
/// decide qué pestañas existen según el rol (y, para el alumno, si tiene
/// proyectos de feria).
enum AppNavDestination { panel, projects, account }

class AppNavTab {
  const AppNavTab({
    required this.destination,
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badgeCount = 0,
  });

  final AppNavDestination destination;
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int badgeCount;
}

/// Barra inferior institucional.
///
/// Sustituye la "píldora" genérica de Material 3 por un indicador fino en el
/// borde superior, ícono relleno y etiqueta en negrita: el patrón sobrio de
/// los portales de servicios públicos, con el color de la organización.
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key, required this.current});

  final AppNavDestination current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isJury = ref.watch(
      authControllerProvider
          .select((s) => AuthRole.usesJuryPanel(s.user?.role)),
    );
    final hasProjects = !isJury && ref.watch(hasStudentProjectsProvider);
    final text = SettingsCopy.of(context);

    final tabs = <AppNavTab>[
      AppNavTab(
        destination: AppNavDestination.panel,
        path: isJury ? '/jury' : '/teaching',
        label: text.t(isJury ? 'Mis ferias' : 'Mi panel'),
        icon: isJury
            ? PhosphorIconsRegular.calendarDots
            : PhosphorIconsRegular.graduationCap,
        selectedIcon: isJury
            ? PhosphorIconsFill.calendarDots
            : PhosphorIconsFill.graduationCap,
      ),
      if (hasProjects)
        AppNavTab(
          destination: AppNavDestination.projects,
          path: '/teaching/projects',
          label: text.t('Mis proyectos'),
          icon: PhosphorIconsRegular.storefront,
          selectedIcon: PhosphorIconsFill.storefront,
        ),
      AppNavTab(
        destination: AppNavDestination.account,
        path: '/account',
        label: text.t(isJury ? 'Mi cuenta' : 'Sobre mí'),
        icon: PhosphorIconsRegular.userCircle,
        selectedIcon: PhosphorIconsFill.userCircle,
      ),
    ];

    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            // Crece con el tamaño de texto elegido para no cortar etiquetas.
            height: 46 + MediaQuery.textScalerOf(context).scale(18),
            child: Row(
              children: [
                for (final tab in tabs)
                  Expanded(
                    child: _NavItem(
                      tab: tab,
                      selected: tab.destination == current,
                      onTap: () {
                        if (tab.destination == current) return;
                        HapticFeedback.selectionClick();
                        context.go(tab.path);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppNavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    final badge = tab.badgeCount > 99 ? '99+' : '${tab.badgeCount}';

    return Semantics(
      button: true,
      selected: selected,
      label: tab.badgeCount > 0 ? '${tab.label}, $badge' : tab.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: scheme.primary.withValues(alpha: 0.06),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              height: 3,
              width: selected ? 32 : 0,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(3)),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Badge(
                    isLabelVisible: tab.badgeCount > 0,
                    label: Text(badge),
                    child: Icon(
                      selected ? tab.selectedIcon : tab.icon,
                      size: AppDimensions.iconLarge,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    tab.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
