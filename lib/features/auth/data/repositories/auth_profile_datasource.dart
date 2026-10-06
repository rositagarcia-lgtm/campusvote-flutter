import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/config/endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_user_model.dart';
import 'auth_repository_impl.dart';

/// Datos del perfil del usuario autenticado: edición de campos propios,
/// subida de la foto de avatar y actualización de la sesión local.
class AuthProfileDataSource {
  AuthProfileDataSource(this._client, this._persister);

  final ApiClient _client;
  final AuthUserPersister _persister;

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  Failure _failureFromApi(ApiResponse<dynamic> r) {
    final err = r.error;
    final message = err?.message ?? r.message ?? 'Error desconocido';
    return UnknownFailure(message: message, code: err?.code);
  }

  AuthUser? _readUser(ApiResponse<Map<String, dynamic>> r) {
    if (!r.success) return null;
    final data = r.data;
    if (data == null || !data.containsKey('id')) return null;
    return AuthUserModel.fromJson(data).toEntity();
  }

  /// Actualiza el perfil propio (`PUT /api/users/me`) y persiste el resultado.
  Future<Result<AuthUser>> updateProfile(Map<String, dynamic> fields) async {
    try {
      final res = await _client.put(ApiEndpoints.updateMe, body: fields);
      debugPrint('>>> updateProfile response: ${res.data}');
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      final user = _readUser(r);
      if (user == null) return FailureResult(_failureFromApi(r));
      await _persister.persistUser(user);
      return Success(user);
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }

  /// Sube la foto de avatar (`POST /api/upload/avatar`) y la enlaza al perfil.
  ///
  /// [file] debe ser una imagen (PNG/JPG/WEBP). El orden importa: primero se
  /// sube el binario y luego se persiste la URL devuelta.
  Future<Result<AuthUser>> updateAvatar(File file) async {
    final mime = _mimeFor(file.path);
    if (mime == null) {
      return const FailureResult(ValidationFailure(
        message: 'Formato no soportado. Usa PNG, JPG o WEBP.',
      ));
    }

    late final String url;
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
          contentType: MediaType.parse(mime),
        ),
      });
      final res = await _client.post(
        ApiEndpoints.uploadAvatar,
        body: form,
        headers: {'Content-Type': 'multipart/form-data'},
      );
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        _asMap(res.data),
        _asMap,
      );
      if (!r.success) return FailureResult(_failureFromApi(r));
      final raw = r.data?['url']?.toString() ?? '';
      debugPrint('>>> avatar raw url: "$raw"');
      if (raw.isEmpty) {
        return const FailureResult(UnknownFailure(
          message: 'El servidor no devolvió la URL de la imagen',
        ));
      }
      url = raw;
    } on DioException catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }

    return updateProfile({'avatar_url': url});
  }

  String? _mimeFor(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.jpg') || p.endsWith('.jpeg')) return 'image/jpeg';
    if (p.endsWith('.webp')) return 'image/webp';
    return null;
  }
}
