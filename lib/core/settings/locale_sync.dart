import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/state/auth_controller.dart';
import '../config/endpoints.dart';
import '../di/core_providers.dart';
import 'app_preferences.dart';

/// Mantiene al servidor al tanto del idioma elegido en la app.
///
/// - Cada petición lleva `Accept-Language`, para que los mensajes de error
///   del backend puedan responder en ese idioma.
/// - Con sesión iniciada, el idioma se guarda en `preferred_locale` del
///   perfil: los correos y avisos que el servidor envía después lo usan.
///
/// Es silencioso a propósito: si el backend aún no acepta el campo, la app
/// sigue funcionando con su traducción local.
void bindLocaleSync(WidgetRef ref) {
  void apply(AppLanguage language, {required bool persist}) {
    final client = ref.read(apiClientProvider);
    client.dio.options.headers['Accept-Language'] = language.code;
    final auth = ref.read(authControllerProvider);
    if (!persist || !auth.authenticated) return;
    client
        .put(ApiEndpoints.updateMe, body: {'preferred_locale': language.code})
        .ignore();
  }

  apply(ref.read(appPreferencesProvider).language, persist: false);
  ref.listenManual(
    appPreferencesProvider.select((p) => p.language),
    (prev, next) {
      if (prev != next) apply(next, persist: true);
    },
  );
}
