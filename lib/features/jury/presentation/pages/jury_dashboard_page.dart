import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_panel_intro.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../notifications/notifications_controller.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import '../widgets/jury_fair_card.dart';

/// `/jury` — dashboard de ferias asignadas (`GET /fairs/my-assignments`).
class JuryDashboardPage extends ConsumerWidget {
  const JuryDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fairs = ref.watch(juryDashboardProvider);
    final unreadCount = ref.watch(notificationsControllerProvider).unreadCount;

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Jurado',
        actions: [
          IconButton(
            tooltip: unreadCount > 0
                ? 'Notificaciones: $unreadCount sin leer'
                : 'Notificaciones',
            onPressed: () => context.push('/jury/notifications'),
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(juryDashboardProvider.notifier).reload(),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/splash');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(juryDashboardProvider.notifier).reload(),
        child: _bodyFor(context, ref, fairs),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
    );
  }
}

/// `AsyncValue` no es una jerarquía sellada, así que el caso por defecto se
/// trata explícitamente en vez de usar un switch exhaustivo.
Widget _bodyFor(
  BuildContext context,
  WidgetRef ref,
  AsyncValue<List<FairAssignmentModel>> fairs,
) {
  switch (fairs) {
    case AsyncLoading():
      return const AppLoader();
    case AsyncError(:final error):
      return AppErrorView(
        message: describeJuryError(error),
        onRetry: () => ref.read(juryDashboardProvider.notifier).reload(),
      );
    case AsyncData(:final value):
      if (value.isEmpty) {
        return const AppEmptyView(
          icon: Icons.event_busy_rounded,
          message: 'No tienes ferias asignadas por ahora.',
        );
      }
      return _FairsList(fairs: value);
    default:
      return const AppLoader();
  }
}

class _FairsList extends ConsumerWidget {
  const _FairsList({required this.fairs});

  final List<FairAssignmentModel> fairs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingControllerProvider);
    final open = fairs.where((f) => f.isOpen).toList(growable: false);
    final others = fairs.where((f) => !f.isOpen).toList(growable: false);
    final theme = Theme.of(context);
    final muted = appMuted(theme.brightness == Brightness.dark);

    return PageScrollBody(
      // Siempre desplazable para que el pull-to-refresh funcione con poco
      // contenido.
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPanelIntro(
            organizationName: branding.name,
            organizationLogoUrl: branding.logoUrl,
            title: 'Tus ferias',
            subtitle:
                'Consulta tus asignaciones y entra a las ferias disponibles.',
            primaryValue: open.length,
            primaryLabel: 'disponibles',
            secondaryValue: fairs.length,
            secondaryLabel: 'asignadas',
          ),
          const SizedBox(height: AppSpacing.l),
          if (open.isNotEmpty) ...[
            SectionHeader(
              label: 'DISPONIBLES',
              title: 'Ferias abiertas',
              count: open.length,
            ),
            ..._cards(open),
          ] else ...[
            Text(
              'No hay ferias abiertas en este momento.',
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ],
          if (others.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              label: 'OTRAS ASIGNACIONES',
              title: 'No disponibles',
              count: others.length,
            ),
            ..._cards(others),
          ],
        ],
      ),
    );
  }

  List<Widget> _cards(List<FairAssignmentModel> list) {
    return [
      for (var i = 0; i < list.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.m),
          child: FairCard(fair: list[i]),
        ),
    ];
  }
}
