import '../../../../core/errors/result.dart';

bool needsReconciliation(Failure failure) =>
    failure is TimeoutFailure ||
    failure is NetworkFailure ||
    failure is ServerFailure ||
    failure is ConflictFailure ||
    failure is UnknownFailure;

String saveFailureMessage(Failure failure) {
  if (failure is NetworkFailure || failure is TimeoutFailure) {
    return 'Sin conexión: tu respuesta no se guardó. Vuelve a marcarla.';
  }
  if (failure is ForbiddenFailure || failure is ValidationFailure) {
    // El backend explica el motivo (jornada cerrada, curso fuera de tu ciclo…).
    return failure.message;
  }
  return submissionFailureMessage(failure);
}

String submissionFailureMessage(Failure failure) {
  if (failure is UnauthorizedFailure) {
    return 'Tu sesión venció. Inicia sesión de nuevo.';
  }
  if (failure is ForbiddenFailure) {
    return 'No tienes permiso para enviar esta evaluación.';
  }
  if (failure is ValidationFailure) {
    return failure.message.isNotEmpty
        ? failure.message
        : 'Revisa tus respuestas antes de continuar.';
  }
  if (failure is NotFoundFailure) {
    return 'Esta asignación ya no está disponible. Actualiza la lista de docentes.';
  }
  return 'No pudimos enviar la evaluación. Revisa el estado antes de intentarlo de nuevo.';
}
