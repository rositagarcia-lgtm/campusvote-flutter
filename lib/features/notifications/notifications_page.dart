import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/app_appbar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/app_notice.dart';
import '../../core/widgets/app_status_chip.dart';
import 'notification_item.dart';
import 'notifications_controller.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: 'Notificaciones',
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed:
                  state.updatingId == 'all' ? null : controller.markAllRead,
              child: const Text('Marcar todas leídas'),
            ),
        ],
      ),
      body: _content(context, state, controller),
    );
  }

  Widget _content(
    BuildContext context,
    NotificationsState state,
    NotificationsController controller,
  ) {
    if (state.loading && state.items.isEmpty) return const AppLoader();
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: AppDimensions.iconLarge * 2),
              const SizedBox(height: AppSpacing.m),
              Text(state.error!, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.m),
              AppButton.outlined(
                label: 'Reintentar',
                icon: Icons.refresh_rounded,
                onPressed: controller.load,
              ),
            ],
          ),
        ),
      );
    }
    if (state.items.isEmpty) {
      return const AppEmptyView(
        icon: Icons.notifications_none_rounded,
        overline: 'AVISOS',
        title: 'Estás al día',
        message: 'Aquí aparecerán los avisos que te envíe CampusVote.',
      );
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          if (state.error != null) ...[
            NoticeBanner(
              message: state.error!,
              tone: AppTone.danger,
              liveRegion: true,
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          for (final notification in state.items) ...[
            _NotificationTile(
              notification: notification,
              loading: state.updatingId == notification.id,
              onTap: () => _open(context, controller, notification),
            ),
            const SizedBox(height: AppSpacing.s),
          ],
          if (controller.hasMore) ...[
            const SizedBox(height: AppSpacing.m),
            AppButton.outlined(
              label: 'Cargar más avisos',
              icon: Icons.expand_more_rounded,
              onPressed: state.loading ? null : controller.loadMore,
              isLoading: state.loading,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Se muestran los avisos más recientes.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    NotificationsController controller,
    NotificationItem item,
  ) async {
    if (!item.isRead && !await controller.markRead(item.id)) return;
    if (!context.mounted) return;
    final fairId = item.metadata['fair_id']?.toString();
    if (fairId != null && fairId.isNotEmpty) {
      context.go('/jury/fair/${Uri.encodeComponent(fairId)}');
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.loading,
    required this.onTap,
  });

  final NotificationItem notification;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = switch (notification.type) {
      'FAIR_OPENED' => 'Feria',
      'SYSTEM_ALERT' => 'Aviso institucional',
      'PROJECT_LIKED' => 'Me gusta',
      'PROJECT_COMMENTED' => 'Comentario',
      'PROJECT_LIKE_MILESTONE' => 'Proyecto',
      'ASSISTED_PROJECT_PREPARED' => 'Proyecto asistido',
      'ASSISTED_PROJECT_CONFIRMED' => 'Proyecto confirmado',
      'JURY_CONFLICT_DECLARED' => 'Conflicto de interés',
      'JURY_RECUSAL_REVOKED' => 'Recusación',
      'RATING_RECEIVED' => 'Calificación',
      _ => 'Notificación',
    };
    final date = notification.createdAt?.toLocal();
    final dateLabel = date == null
        ? null
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return Semantics(
      button: true,
      enabled: !loading,
      onTap: loading ? null : onTap,
      label:
          '$typeLabel. ${notification.title}. ${notification.isRead ? 'Leída' : 'No leída'}',
      excludeSemantics: true,
      child: AppCard(
        onTap: loading ? null : onTap,
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              notification.isRead
                  ? Icons.notifications_none_rounded
                  : Icons.notifications_active_outlined,
              color: notification.isRead
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.primary,
              size: AppDimensions.iconLarge,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(typeLabel, style: theme.textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notification.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(notification.message, style: theme.textTheme.bodySmall),
                  if (dateLabel != null) ...[
                    const SizedBox(height: AppSpacing.s),
                    Text(dateLabel, style: theme.textTheme.labelSmall),
                  ],
                ],
              ),
            ),
            if (loading)
              const SizedBox(
                width: AppDimensions.iconMedium,
                height: AppDimensions.iconMedium,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (!notification.isRead)
              Icon(Icons.circle, size: 9, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
