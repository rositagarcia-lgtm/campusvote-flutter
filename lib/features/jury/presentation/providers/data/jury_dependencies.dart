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
    final transportCode = error.code?.toLowerCase() ?? '';
    if (error.statusCode == null) {
      return switch (transportCode) {
        'connectiontimeout' ||
        'sendtimeout' ||
        'receivetimeout' =>
          'La solicitud tardó demasiado. Comprueba tu conexión e inténtalo de nuevo.',
        'connectionerror' || 'badcertificate' =>
          'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo.',
        _ => 'No se pudo completar la operación. Inténtalo de nuevo.',
      };
    }
    // El backend es la autoridad de esta regla: su mensaje ya indica cuántas
    // rúbricas faltan. Los demás 409 permanecen generalizados para no exponer
    // detalles internos.
    if (transportCode == 'rubrics_incomplete' && error.message.isNotEmpty) {
      return error.message;
    }
    final schedule = _fairScheduleMessage(error.message);
    if (error.statusCode == 409 && schedule != null) return schedule;
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
      _ => 'No se pudo completar la operación. Inténtalo de nuevo.',
    };
  }
  return 'No se pudo completar la operación.';
}

/// El 409 de horario trae un texto claro. El resto de los 409 sigue oculto.
String? _fairScheduleMessage(String message) {
  final text = message.toLowerCase();
  if (text.contains('cuando inicia la feria') ||
      text.contains('mientras la feria está abierta')) {
    return 'Aún no es el momento. Espera a que la feria empiece.';
  }
  if (text.contains('período de evaluación') && text.contains('terminó')) {
    return 'La feria ya terminó. Ya no se puede responder la rúbrica.';
  }
  return null;
}
