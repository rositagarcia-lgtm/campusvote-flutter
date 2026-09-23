import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/core_providers.dart';
import '../core/network/api_interceptor.dart';
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
        () => ref.read(authRepositoryProvider) as AuthRefresher,
        events,
      );
    }),
  ];
}

class _ForcedLogoutAdapter implements AuthRefresher {
  _ForcedLogoutAdapter(AuthRefresher Function() inner, AuthEventsController events)
      : _inner = inner,
        _events = events;

  /// Se llama en el momento del refresh, no al arrancar la app.
  final AuthRefresher Function() _inner;
  final AuthEventsController _events;

  @override
  Future<bool> tryRefresh() => _inner().tryRefresh();

  @override
  Future<void> logout() async {
    await _inner().logout();
    _events.notifyForcedLogout();
  }
}

/// Inicializa el auth controller como parte del bootstrap.
Future<void> initializeApp(ProviderContainer container) async {
  container.read(authControllerProvider);
}