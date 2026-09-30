/// Resultado funcional estilo Either (success | failure).
///
/// Se prefiere sobre `Future<Election?>` con excepciones dispersas.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        FailureResult<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        FailureResult<T>(:final failure) => failure,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure f) failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      FailureResult<T>(failure: final f) => failure(f),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);
}

/// Jerarquía de errores de dominio.
///
/// Nunca exponer `DioException` o `SocketException` a la UI.
sealed class Failure {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const Failure({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  @override
  String toString() =>
      '$runtimeType(message: $message, code: $code, status: $statusCode)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sin conexión a internet',
    String? code,
  }) : super(code: code ?? 'NETWORK');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'La solicitud tardó demasiado',
    String? code,
  }) : super(code: code ?? 'TIMEOUT');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Sesión expirada. Inicia sesión nuevamente.',
    String? code,
  }) : super(code: code ?? 'UNAUTHORIZED', statusCode: 401);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'No tienes permisos para realizar esta acción.',
    String? code,
  }) : super(code: code ?? 'FORBIDDEN', statusCode: 403);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Recurso no encontrado',
    String? code,
  }) : super(code: code ?? 'NOT_FOUND', statusCode: 404);
}

class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message = 'El estado del recurso cambió. Intenta de nuevo.',
    String? code,
  }) : super(code: code ?? 'CONFLICT', statusCode: 409);
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION',
    super.details,
  }) : super(statusCode: 422);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({
    super.message = 'Demasiadas solicitudes. Intenta en unos minutos.',
    String? code,
  }) : super(code: code ?? 'RATE_LIMIT', statusCode: 429);
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Error interno del servidor',
    String? code,
  }) : super(code: code ?? 'SERVER', statusCode: 500);
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Ocurrió un error inesperado',
    String? code,
  }) : super(code: code ?? 'UNKNOWN');
}
