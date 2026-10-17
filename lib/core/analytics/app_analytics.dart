import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics sin datos personales: solo pantallas y acciones de uso.
/// Nunca se envían correos, nombres, IDs de usuario ni tokens de enlaces.
/// Si Firebase no está configurado (p. ej. iOS sin GoogleService-Info.plist)
/// la app sigue funcionando y simplemente no se mide nada.
class AppAnalytics {
  AppAnalytics._();

  static FirebaseAnalytics? _analytics;
  static String? _lastScreen;

  static final _uuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  static final _token = RegExp(r'^[A-Za-z0-9_-]{20,}$');

  static Future<void> init() async {
    // Las pruebas y el modo debug no ensucian las métricas reales.
    if (!kReleaseMode) return;
    try {
      await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(true);
    } catch (_) {
      _analytics = null;
    }
  }

  /// Ruta sin IDs ni tokens: `/jury/fair/<uuid>/vote` → `/jury/fair/:id/vote`.
  static String sanitize(String location) {
    final path = location.split('?').first;
    return path.split('/').map((s) {
      if (_uuid.hasMatch(s)) return ':id';
      if (_token.hasMatch(s)) return ':token';
      return s;
    }).join('/');
  }

  static void screen(String location) {
    final name = sanitize(location);
    if (_analytics == null || name == _lastScreen) return;
    _lastScreen = name;
    _analytics!.logScreenView(screenName: name, screenClass: name);
  }

  /// Acción de uso. `params` sin datos personales (solo tipos o conteos).
  static void event(String name, [Map<String, Object>? params]) {
    _analytics?.logEvent(name: name, parameters: params);
  }
}
