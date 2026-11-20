import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/core_providers.dart';
import '../core/network/api_interceptor.dart';
import '../core/push/push_sync.dart';
import '../core/storage/local_storage.dart';
import '../features/auth/data/datasources/auth_user_persister.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/state/auth_controller.dart';
import '../features/auth/presentation/state/auth_events.dart';
import '../features/auth/presentation/state/auth_providers.dart';

/// ProviderScope que sobreescribe los providers que requieren inicialización.
final appBootstrappedProvider = Provider<bool>((ref) => false);

Future<List<Override>> appBootstrapOverrides() async {
  final local = await LocalStorage.create();
  return [
    localStorageProvider.overrideWithValue(local),
    authUserPersisterProvider.overrideWith(
      (ref) => SharedPrefsAuthUserPersister(ref.watch(localStorageProvider)),
    ),
    authRepositoryProvider.overrideWith((ref) {
      final impl = AuthRepositoryImpl(
        client: ref.watch(apiClientProvider),
        persister: ref.watch(authUserPersisterProvider),
      );
      return impl;
    }),
    // El refresher que usa el interceptor. Cuando el refresh falla y se hace
    // logout forzado, emitimos un evento global para que el auth controller
    // y el router limpien su estado.
    authRefresherProvider.overrideWith((ref) {
      final events = ref.read(authEventsProvider.notifier);
      // El repositorio se resuelve al usarlo, no al construir el provider.
      // Con `ref.watch` aquí el grafo quedaba en círculo —apiClient →
      // authRefresher → authRepository → apiClient— y Riverpod lanzaba
      // CircularDependencyError: la app se quedaba en la pantalla de carga.
      // AuthRepositoryImpl implementa AuthRefresher (ver auth_repository_impl.dart),
      // por eso el cast es válido.
      return _ForcedLogoutAdapter(
        ref,
        () => ref.read(authRepositoryProvider) as AuthRefresher,
        events,
      );
    }),
  ];
}

class _ForcedLogoutAdapter implements AuthRefresher {
  _ForcedLogoutAdapter(this._ref, this._inner, this._events);

  final Ref _ref;

  /// Se llama en el momento del refresh, no al arrancar la app.
  final AuthRefresher Function() _inner;
  final AuthEventsController _events;

  @override
  Future<RefreshOutcome> tryRefresh() => _inner().tryRefresh();

  @override
  Future<void> logout() async {
    try {
      // Antes de borrar el access token: el endpoint dedicado acepta el JWT
      // expirado y borra solo el FCM token de este usuario. `skipAuthRefresh`
      // evita que su 401 vuelva a entrar aquí.
      await unregisterPushDevice(_ref, forced: true);
    } catch (_) {
      // No debe impedir el cierre de sesión local si falla Firebase o la red.
    }
    try {
      await _inner().logout();
    } catch (_) {
      // Garantiza que el evento de logout forzado se dispare incluso si
      // falla la llamada remota al endpoint /auth/logout.
    } finally {
      _events.notifyForcedLogout();
    }
  }
}

/// Inicializa el auth controller como parte del bootstrap.
Future<void> initializeApp(ProviderContainer container) async {
  container.read(authControllerProvider);
}