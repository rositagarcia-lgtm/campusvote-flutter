import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/organization_panel_app_bar.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../notifications/notifications_controller.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_dashboard_progress.dart';
import '../providers/jury_providers.dart';
import '../widgets/jury_dashboard_overview.dart';
import '../widgets/jury_fair_card.dart';

/// `/jury` — dashboard de ferias asignadas (`GET /fairs/my-assignments`).
class JuryDashboardPage extends ConsumerWidget {
  const JuryDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fairs = ref.watch(juryDashboardProvider);
    final branding = ref.watch(brandingControllerProvider);
    final unreadCount = ref.watch(notificationsControllerProvider).unreadCount;

    return Scaffold(
      appBar: OrganizationPanelAppBar(
        branding: branding,
        section: 'Panel del jurado',
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
          PopupMenuButton<String>(
            tooltip: 'Perfil y sesi\u00f3n',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) async {
              if (value == 'account') {
                if (context.mounted) context.go('/account');
              } else if (value == 'refresh') {
                await _reload(ref);
              } else if (value == 'signout') {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/splash');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.refresh_rounded),
                  title: Text('Actualizar ferias'),
                ),
              ),
              PopupMenuItem(
                value: 'account',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.person_outline_rounded),
                  title: Text('Mi cuenta'),
                ),
              ),
              PopupMenuItem(
                value: 'signout',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Cerrar sesi\u00f3n'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _reload(ref),
        child: _bodyFor(context, ref, fairs),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
    );
  }
}

Future<void> _reload(WidgetRef ref) async {
  final current = ref.read(juryDashboardProvider).valueOrNull;
  for (final fair in current ?? const <FairAssignmentModel>[]) {
    if (fair.isOpen) ref.invalidate(juryProgressProvider(fair.fairId));
  }
  await ref.read(juryDashboardProvider.notifier).reload();
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
          overline: 'ASIGNACIONES',
          title: 'Aún no tienes ferias asignadas',
          message:
              'Cuando la organización te asigne una feria, aparecerá aquí. Desliza hacia abajo para actualizar.',
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
    final progress = ref.watch(juryDashboardProgressProvider);
    final open = fairs.where((f) => f.isOpen).toList(growable: false);
    final others = fairs.where((f) => !f.isOpen).toList(growable: false);
    return PageScrollBody(
      // Siempre desplazable para permitir actualizar con poco contenido.
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JuryDashboardOverview(
            openCount: open.length,
            assignedCount: fairs.length,
            progress: progress,
          ),
          const SizedBox(height: AppSpacing.l),
          if (open.isNotEmpty) ...[
            SectionHeader(
              label: 'ACCESO DISPONIBLE',
              title: 'Ferias abiertas',
              count: open.length,
            ),
            ..._cards(open),
          ] else ...[
            const NoticeBanner(
              tone: AppTone.info,
              icon: Icons.event_busy_outlined,
              message:
                  'Por ahora no tienes ferias abiertas. Revisa tus otras asignaciones m\u00e1s abajo.',
            ),
          ],
          if (others.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              label: 'ASIGNACIONES',
              title: 'Otras asignaciones',
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
