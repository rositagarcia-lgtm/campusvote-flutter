import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/state/auth_controller.dart';
import '../../features/settings/presentation/settings_copy.dart';
import '../settings/app_preferences.dart';
import '../../features/notifications/notifications_controller.dart';
import '../config/endpoints.dart';
import '../di/core_providers.dart';
import 'app_push.dart';

/// Une los avisos push con la sesión y la navegación:
///
/// - Con sesión iniciada registra el celular en el servidor (y cada vez que
///   Firebase renueva el token).
/// - Un aviso con la app abierta refresca la campana y se muestra en
///   [messenger].
/// - Tocar un aviso del sistema abre la bandeja.
///
/// Al cerrar sesión, [unregisterPushDevice] quita el celular antes de borrar
/// el token de acceso, para que no le lleguen avisos de la cuenta anterior.
void bindPushSync(
  WidgetRef ref,
  GoRouter router,
  GlobalKey<ScaffoldMessengerState> messenger,
) {
  if (!AppPush.available) return;

  Future<void> register(String? token) async {
    if (token == null || !ref.read(authControllerProvider).authenticated) {
      return;
    }
    await ref.read(apiClientProvider).post(NotificationEndpoints.devices,
        body: {
          'token': token,
          'platform': AppPush.platform
        }).then((_) {}, onError: (_) {});
  }

  void openInbox() => router.go('/notifications');

  ref.listenManual(
    authControllerProvider.select((s) => s.authenticated),
    (prev, next) async {
      if (next && prev != true) await register(await AppPush.requestToken());
    },
    fireImmediately: true,
  );
  AppPush.onTokenRefresh.listen(register);
  AppPush.onOpened.listen((_) => openInbox());
  AppPush.initialMessage().then((message) {
    if (message != null) openInbox();
  });
  AppPush.onForeground.listen((message) {
    ref.invalidate(notificationsControllerProvider);
    final title = message.notification?.title;
    if (title == null) return;
    messenger.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(title),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label:
              SettingsCopy(ref.read(appPreferencesProvider).language).t('Ver'),
          onPressed: openInbox,
        ),
      ));
  });
}

/// Quita este celular de la cuenta. Nunca bloquea el cierre de sesión.
///
/// En logout forzado el access token puede estar expirado: se usa la ruta
/// dedicada del backend y se marca `skipAuthRefresh` para que un 401 no
/// vuelva a disparar refresh → logout → este mismo desregistro.
Future<void> unregisterPushDevice(Ref ref, {bool forced = false}) async {
  final token = await AppPush.currentToken();
  if (token == null) return;
  final dio = ref.read(apiClientProvider).dio;

  Future<void> remove(String path) => dio
      .delete(
        path,
        data: {'token': token},
        options: Options(extra: const {'skipAuthRefresh': true}),
      )
      .timeout(const Duration(seconds: 4));

  try {
    await remove(forced
        ? NotificationEndpoints.devicesOnLogout
        : NotificationEndpoints.devices);
  } on DioException catch (e) {
    // Backend anterior sin la ruta de logout: se mantiene compatibilidad con
    // la instalación actual mientras el token siga siendo válido.
    if (forced && e.response?.statusCode == 404) {
      try {
        await remove(NotificationEndpoints.devices);
      } catch (_) {}
    }
  } catch (_) {}
}
