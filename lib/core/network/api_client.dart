import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_env.dart';
import '../storage/secure_storage.dart';
import 'api_interceptor.dart';

/// Cliente REST centralizado (Dio).
///
/// El interceptor se inyecta por separado para evitar referencias cíclicas
/// con `AuthRepository`.
class ApiClient {
  ApiClient({required SecureStorage storage, AuthInterceptor? interceptor})
      : _storage = storage {
    _dio = Dio(BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      responseType: ResponseType.json,
      validateStatus: (s) => s != null && s < 600,
    ));

    if (interceptor != null) {
      _dio.interceptors.add(interceptor);
    }

    if (AppEnv.isDevelopment) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
        logPrint: (o) => debugPrint('[HTTP] $o'),
      ));
    }
  }

  late final Dio _dio;
  final SecureStorage _storage;

  Dio get dio => _dio;
  SecureStorage get storage => _storage;

  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic>? query}) async {
    return _dio.get(path, queryParameters: query);
  }

  Future<Response<dynamic>> post(String path,
      {Object? body,
      Map<String, dynamic>? query,
      Map<String, dynamic>? headers}) async {
    return _dio.post(
      path,
      data: body,
      queryParameters: query,
      options: headers != null ? Options(headers: headers) : null,
    );
  }

  Future<Response<dynamic>> patch(String path, {Object? body}) {
    return _dio.patch(path, data: body);
  }

  Future<Response<dynamic>> put(String path, {Object? body}) {
    return _dio.put(path, data: body);
  }

  Future<Response<dynamic>> delete(String path) => _dio.delete(path);
}
