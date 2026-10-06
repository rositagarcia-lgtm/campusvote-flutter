import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_role.dart';
import '../../features/auth/presentation/state/auth_controller.dart';

/// Navegación estable para el panel del rol y el perfil.
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isJury = ref.watch(
      authControllerProvider.select((s) => s.user?.role == AuthRole.jury),
    );
    void onSelect(int index) {
      if (index == selectedIndex) return;
      HapticFeedback.selectionClick();
      context.go(index == 0 ? (isJury ? '/jury' : '/teaching') : '/account');
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      destinations: [
        NavigationDestination(
          icon:
              Icon(isJury ? Icons.event_note_outlined : Icons.school_outlined),
          selectedIcon:
              Icon(isJury ? Icons.event_note_rounded : Icons.school_rounded),
          label: isJury ? 'Mis ferias' : 'Mi panel',
          tooltip: isJury ? 'Ferias asignadas' : 'Panel acad\u00e9mico',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: isJury ? 'Mi cuenta' : 'Sobre m\u00ed',
          tooltip: 'Mi cuenta',
        ),
      ],
    );
  }
}
