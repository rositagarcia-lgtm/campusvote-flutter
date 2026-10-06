import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/branding/branding_controller.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/app_notice.dart';
import '../../core/widgets/app_status_chip.dart';
import '../../core/widgets/organization_panel_app_bar.dart';
import 'notification_item.dart';
import 'notification_presentation.dart';
import 'notification_widgets.dart';
import 'notifications_controller.dart';
import 'notifications_state.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  NotificationFilter _filter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    final branding = ref.watch(brandingControllerProvider);
    return Scaffold(
      appBar: OrganizationPanelAppBar(
        branding: branding,
        section: 'Notificaciones',
        onBack: () => context.pop(),
        actions: [
          IconButton(
            tooltip: 'Marcar todas como leídas',
            onPressed: state.unreadCount > 0 && state.updatingId != 'all'
                ? controller.markAllRead
                : null,
            icon: const Icon(Icons.done_all_rounded),
          ),
        ],
      ),
      body: _content(state, controller),
    );
  }

  Widget _content(
      NotificationsState state, NotificationsController controller) {
    if (state.loading && state.items.isEmpty) {
      return const AppLoader();
    }
    if (state.error != null && state.items.isEmpty) {
      return _ErrorRetry(
        message: state.error!,
        onRetry: controller.load,
      );
    }
    if (state.items.isEmpty) {
      return const AppEmptyView(
        icon: Icons.notifications_none_rounded,
        overline: 'AVISOS',
        title: 'Estás al día',
        message: 'Aquí aparecerán los avisos de tu organización.',
      );
    }

    final visible = state.items
        .where((item) => matchesNotificationFilter(item, _filter))
        .toList(growable: false);
    final now = DateTime.now();
    final grouped = <String, List<NotificationItem>>{};
    for (final item in visible) {
      grouped
          .putIfAbsent(notificationDateGroup(item.createdAt, now), () => [])
          .add(item);
    }
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.m,
          AppSpacing.l,
          AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text('TUS AVISOS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              )),
          const SizedBox(height: AppSpacing.xs),
          Text('Mostrando ${state.items.length} de ${state.total} avisos',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: AppSpacing.m),
          NotificationFilterBar(
            selected: _filter,
            items: state.items,
            onSelected: (filter) => setState(() => _filter = filter),
          ),
          const SizedBox(height: AppSpacing.l),
          if (state.error != null) ...[
            NoticeBanner(
                message: state.error!, tone: AppTone.danger, liveRegion: true),
            const SizedBox(height: AppSpacing.m),
          ],
          if (visible.isEmpty)
            const NoticeBanner(
              message:
                  'No hay avisos en este filtro. Puedes cargar más avisos.',
              tone: AppTone.info,
              icon: Icons.filter_alt_off_outlined,
            ),
          for (final group in grouped.entries) ...[
            NotificationDateHeader(
                label: group.key, count: group.value.length),
            const SizedBox(height: AppSpacing.m),
            for (final item in group.value) ...[
              NotificationCard(
                notification: item,
                loading: state.updatingId == item.id,
                onTap: () => _open(controller, item),
              ),
              const SizedBox(height: AppSpacing.m),
            ],
          ],
          if (controller.hasMore) ...[
            AppButton.outlined(
              label: 'Cargar más avisos',
              icon: Icons.expand_more_rounded,
              onPressed: state.loading ? null : controller.loadMore,
              isLoading: state.loading,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _open(
      NotificationsController controller, NotificationItem item) async {
    if (!item.isRead && !await controller.markRead(item.id)) return;
    if (!mounted) return;
    final fairId = item.metadata['fair_id']?.toString();
    if (fairId != null && fairId.isNotEmpty) {
      context.go('/jury/fair/${Uri.encodeComponent(fairId)}');
    }
  }
}

/// Fallo de carga sin avisos en caché: reintento a la vista.
class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: AppDimensions.iconLarge * 2),
            const SizedBox(height: AppSpacing.m),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.m),
            AppButton.outlined(
              label: 'Reintentar',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}