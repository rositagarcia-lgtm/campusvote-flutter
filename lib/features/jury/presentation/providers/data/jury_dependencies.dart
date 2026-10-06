// data/jury_dependencies.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/di/core_providers.dart';
import '../../../data/datasources/jury_remote_datasource.dart';
import '../../../data/repositories/jury_repository_impl.dart';
import '../../../domain/repositories/jury_repository.dart';

// ── Inyección ───────────────────────────────────────────────────────────────

final juryRemoteDataSourceProvider = Provider<JuryRemoteDataSource>((ref) {
  return JuryRemoteDataSource(ref.watch(apiClientProvider));
});

final juryRepositoryProvider = Provider<JuryRepository>((ref) {
  return JuryRepositoryImpl(ref.watch(juryRemoteDataSourceProvider));
});

/// Convierte fallos de red/API en mensajes útiles sin mostrar respuestas,
/// códigos ni detalles internos del servidor.
String describeJuryError(Object error) {
  if (error is JuryApiException) {
    return switch (error.statusCode) {
      400 =>
        'No pudimos validar la información. Revísala e inténtalo de nuevo.',
      401 => 'Tu sesión venció. Inicia sesión nuevamente.',
      403 => 'No tienes permisos para realizar esta acción.',
      404 => 'La información ya no está disponible. Actualiza la pantalla.',
      409 =>
        'El estado cambió o esta acción ya se registró. Actualiza la información.',
      int status when status >= 500 =>
        'El servicio no está disponible por el momento. Inténtalo más tarde.',
      null => 'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo.',
      _ => 'No se pudo completar la operación. Inténtalo de nuevo.',
    };
  }
  return 'No se pudo completar la operación.';
}
