import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../settings/presentation/settings_copy.dart';
import '../../notifications_controller.dart';

/// Campana de avisos para la barra superior del jurado.
///
/// Los avisos son algo que se consulta de vez en cuando, no un destino de
/// trabajo: viven arriba, como en cualquier app institucional, y el contador
/// "late" al llegar uno nuevo.
class NotificationsBell extends ConsumerWidget {
  const NotificationsBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(
      notificationsControllerProvider.select((s) => s.unreadCount),
    );
    final text = SettingsCopy.of(context);
    final label = unread > 99 ? '99+' : '$unread';

    return IconButton(
      tooltip: unread > 0
          ? '${text.t('Avisos')}: $label ${text.t('sin leer')}'
          : text.t('Avisos'),
      onPressed: () => context.push('/jury/notifications'),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: TweenAnimationBuilder<double>(
          key: ValueKey(unread),
          tween: Tween(begin: AppMotion.reduced(context) ? 1 : 0.4, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (_, s, child) => Transform.scale(scale: s, child: child),
          child: Text(label),
        ),
        child: Icon(
          unread > 0 ? PhosphorIconsFill.bell : PhosphorIconsRegular.bell,
        ),
      ),
    );
  }
}
