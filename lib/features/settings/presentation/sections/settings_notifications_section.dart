// settings_notifications_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/endpoints.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/push/app_push.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../settings_copy.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_section_label.dart';

/// Bloque NOTIFICACIONES: comprueba de verdad que el push llega a este celular.
///
/// Pide permiso, registra el celular y le pide al servidor un aviso de prueba;
/// el resultado explica qué falta si no llega (permiso, registro o servidor).
class SettingsNotificationsSection extends ConsumerStatefulWidget {
  const SettingsNotificationsSection({super.key});

  @override
  ConsumerState<SettingsNotificationsSection> createState() =>
      _SettingsNotificationsSectionState();
}

class _SettingsNotificationsSectionState
    extends ConsumerState<SettingsNotificationsSection> {
  bool _sending = false;
  String? _result;

  Future<void> _test() async {
    final text = SettingsCopy.of(context);
    setState(() {
      _sending = true;
      _result = null;
    });
    final token = await AppPush.requestToken();
    String result;
    if (!AppPush.available) {
      result = text.t('Este celular no tiene el servicio de notificaciones.');
    } else if (token == null) {
      result = text.t(
          'Activa el permiso de notificaciones de CampusVote en los ajustes del celular.');
    } else {
      try {
        final api = ref.read(apiClientProvider);
        await api.post(NotificationEndpoints.devices,
            body: {'token': token, 'platform': AppPush.platform});
        final res = await api.post(NotificationEndpoints.devicesTest);
        final data = res.data is Map ? (res.data as Map)['data'] : null;
        final sent = data is Map && data['sent'] is num ? data['sent'] as num : 0;
        result = sent > 0
            ? text.t('Listo: en unos segundos te llega una notificación de prueba.')
            : text.t('El servidor no pudo enviar el aviso. Inténtalo más tarde.');
      } catch (_) {
        result = text.t('No pudimos contactar al servidor. Revisa tu conexión.');
      }
    }
    if (!mounted) return;
    setState(() {
      _sending = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    final signedIn = ref.watch(authControllerProvider.select((s) => s.authenticated));
    if (!signedIn) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionLabel(label: text.t('NOTIFICACIONES')),
        const SizedBox(height: AppSpacing.m),
        SettingsGroup(
          children: [
            SettingsRow(
              icon: PhosphorIconsRegular.bellRinging,
              title: text.t('Enviar notificación de prueba'),
              subtitle: _result ??
                  text.t('Comprueba que los avisos de ferias y resultados llegan a este celular.'),
              onTap: _sending ? null : _test,
              trailing: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : Icon(PhosphorIconsRegular.paperPlaneTilt,
                      color: theme.colorScheme.primary),
            ),
          ],
        ),
      ],
    );
  }
}
