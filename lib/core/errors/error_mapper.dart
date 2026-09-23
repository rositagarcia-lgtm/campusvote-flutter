import 'dart:async';

import 'package:dio/dio.dart';

import '../errors/result.dart';

/// Mapea cualquier excepción (Dio / red / formato) a [Failure].
Failure mapExceptionToFailure(Object error) {
  if (error is DioException) {
    return _mapDio(error);
  }
  if (error is TimeoutException) {
    return const TimeoutFailure();
  }
  return UnknownFailure(message: error.toString());
}

Failure _mapDio(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutFailure();
    case DioExceptionType.connectionError:
      // Aquí caen tres cosas distintas y no hay forma de separarlas: que no
      // haya red, que el servidor esté caído y —en web— que el navegador
      // bloquee la petición por CORS. Por eso el mensaje no afirma que falte
      // internet: decirlo mandaba a revisar el wifi cuando el problema era
      // que el backend rechazaba el origen.
      return const NetworkFailure(
        message: 'No se pudo contactar al servidor. '
            'Revisa tu conexión o inténtalo más tarde.',
      );
    case DioExceptionType.badCertificate:
      return const NetworkFailure(message: 'Certificado inválido');
    case DioExceptionType.cancel:
      return const UnknownFailure(message: 'Solicitud cancelada');
    case DioExceptionType.badResponse:
      return _mapResponse(error.response);
    case DioExceptionType.unknown:
    case DioExceptionType.transformTimeout:
      return const UnknownFailure(message: 'Error desconocido de red');
  }
}

Failure _mapResponse(Response<dynamic>? response) {
  final code = response?.statusCode ?? 0;
  final body = response?.data;
  final errorBody = (body is Map && body['error'] is Map)
      ? body['error'] as Map
      : null;
  final message = (errorBody?['message'] as String?) ??
      (body is Map && body['message'] is String
          ? body['message'] as String
          : 'Error $code');
  final errCode = errorBody?['code'] as String?;
  final details = errorBody?['details'];

  switch (code) {
    case 400:
      return ValidationFailure(
        message: message,
        code: errCode,
        details: details is Map ? details as Map<String, dynamic> : null,
      );
    case 401:
      return UnauthorizedFailure(message: message, code: errCode);
    case 403:
      return ForbiddenFailure(message: message, code: errCode);
    case 404:
      return NotFoundFailure(message: message, code: errCode);
    case 409:
      return ConflictFailure(message: message, code: errCode);
    case 422:
      return ValidationFailure(
        message: message,
        code: errCode,
        details: details is Map ? details as Map<String, dynamic> : null,
      );
    case 429:
      return RateLimitFailure(message: message);
    default:
      if (code >= 500) return ServerFailure(message: message, code: errCode);
      return UnknownFailure(message: message, code: errCode);
  }
}