import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Avisos push (Firebase Cloud Messaging).
///
/// Con la app cerrada o en segundo plano, Android e iOS muestran el aviso
/// solos (el servidor manda `notification`). Con la app abierta, [onForeground]
/// avisa a la interfaz para refrescar la campana y mostrar un aviso breve.
///
/// Si Firebase no está configurado, todo queda en silencio: la bandeja de la
/// app sigue funcionando igual.
class AppPush {
  AppPush._();

  static FirebaseMessaging? _messaging;
  static final _foreground = StreamController<RemoteMessage>.broadcast();
  static final _opened = StreamController<RemoteMessage>.broadcast();

  /// Aviso recibido con la app abierta.
  static Stream<RemoteMessage> get onForeground => _foreground.stream;

  /// El usuario tocó un aviso del sistema (app en segundo plano o cerrada).
  static Stream<RemoteMessage> get onOpened => _opened.stream;

  static bool get available => _messaging != null;

  static String get platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  static Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      // iOS: con la app abierta también se muestra el banner del sistema.
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onMessage.listen(_foreground.add);
      FirebaseMessaging.onMessageOpenedApp.listen(_opened.add);
      _messaging = messaging;
    } catch (_) {
      _messaging = null;
    }
  }

  /// Aviso que abrió la app desde cerrada; se entrega una sola vez.
  static Future<RemoteMessage?> initialMessage() async {
    try {
      return await _messaging?.getInitialMessage();
    } catch (_) {
      return null;
    }
  }

  /// Pide permiso (Android 13+ e iOS) y devuelve el token, o null si el
  /// usuario no lo concede o Firebase no está disponible.
  static Future<String?> requestToken() async {
    final messaging = _messaging;
    if (messaging == null) return null;
    try {
      final settings = await messaging.requestPermission();
      final allowed = settings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!allowed) return null;
      // El servidor (firebase-admin) envía por token de registro; register()
      // entrega un FID, que todavía no usa. Se migra cuando el servidor lo haga.
      // ignore: deprecated_member_use
      return await messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  static Stream<String> get onTokenRefresh =>
      // ignore: deprecated_member_use
      _messaging?.onTokenRefresh ?? const Stream.empty();

  /// Token actual sin volver a pedir permiso (para quitarlo al cerrar sesión).
  static Future<String?> currentToken() async {
    try {
      // ignore: deprecated_member_use
      return await _messaging?.getToken();
    } catch (_) {
      return null;
    }
  }
}
