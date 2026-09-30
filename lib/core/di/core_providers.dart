import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_interceptor.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

/// Provider raíz de almacenamiento seguro.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Provider raíz de almacenamiento local (SharedPreferences).
final localStorageProvider = Provider<LocalStorage>((ref) {
  throw UnimplementedError(
    'LocalStorage debe ser sobreescrito en ProviderScope con la instancia inicializada.',
  );
});

/// Refresher de tokens para el interceptor.
///
/// Antes del login el bootstrap lo sobreescribe con la implementación real
/// (`AuthRepositoryImpl`) que puede refrescar tokens válidos.
final authRefresherProvider = Provider<AuthRefresher>((ref) {
  return _NoopRefresher();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final refresher = ref.watch(authRefresherProvider);
  final interceptor = AuthInterceptor(
    client: ApiClient(storage: storage),
    refresher: refresher,
  );
  return ApiClient(storage: storage, interceptor: interceptor);
});

class _NoopRefresher implements AuthRefresher {
  @override
  Future<bool> tryRefresh() async => false;

  @override
  Future<void> logout() async {}
}
