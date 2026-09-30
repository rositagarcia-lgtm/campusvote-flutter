import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_role.dart';
import '../../features/auth/presentation/state/auth_controller.dart';

/// Barra de navegación inferior compartida por los paneles.
///
/// - destino 0: el panel del rol (jurado → ferias, resto → docentes).
/// - destino 1: "Sobre mí" (perfil, foto, seguridad, salir).
class AppBottomNav extends ConsumerWidget {
  final int selectedIndex;

  const AppBottomNav({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isJury = ref.watch(
      authControllerProvider.select((s) => s.user?.role == AuthRole.jury),
    );
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          elevation: 0,
          height: 68,
          backgroundColor: Colors.transparent,
          indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.14),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) {
            if (i == selectedIndex) return;
            if (i == 0) {
              context.go(isJury ? '/jury' : '/teaching');
            } else {
              context.go('/account');
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                isJury ? Icons.gavel_outlined : Icons.school_outlined,
              ),
              selectedIcon: Icon(
                isJury ? Icons.gavel_rounded : Icons.school_rounded,
              ),
              label: 'Mi panel',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Sobre mí',
            ),
          ],
        ),
      ),
    );
  }
}
