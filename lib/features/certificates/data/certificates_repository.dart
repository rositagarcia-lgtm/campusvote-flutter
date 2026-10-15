import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/network/api_client.dart';

/// Certificado de feria del usuario (participación o ganador).
class MyCertificate {
  const MyCertificate({
    required this.id,
    required this.winner,
    required this.fairName,
    required this.projectName,
    this.category,
    this.issuedAt,
  });

  final String id;
  final bool winner;
  final String fairName;
  final String projectName;
  final String? category;
  final DateTime? issuedAt;

  factory MyCertificate.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> map(Object? v) =>
        v is Map ? Map<String, dynamic>.from(v) : const {};
    final fair = map(json['fair']);
    final project = map(json['project']);
    final category = '${project['category'] ?? ''}'.trim();
    return MyCertificate(
      id: '${json['id'] ?? ''}',
      winner: json['certificate_type'] == 'WINNER',
      fairName: '${fair['name'] ?? 'Feria'}',
      projectName: '${project['name'] ?? 'Proyecto'}',
      category: category.isEmpty ? null : category,
      issuedAt: DateTime.tryParse('${json['issue_date'] ?? ''}'),
    );
  }
}

class CertificatesRepository {
  CertificatesRepository(this._client);
  final ApiClient _client;

  Future<List<MyCertificate>> mine() async {
    final response = await _client.get(ApiEndpoints.myCertificates);
    _check(response, ApiEndpoints.myCertificates);
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    final list = data is Map ? data['certificates'] : null;
    return [
      for (final c in list is List ? list : const [])
        if (c is Map) MyCertificate.fromJson(Map<String, dynamic>.from(c)),
    ];
  }

  /// Descarga el PDF a la carpeta temporal y devuelve el archivo.
  Future<File> download(MyCertificate certificate) async {
    final path = ApiEndpoints.certificatePdf(certificate.id);
    final response = await _client.dio.get<List<int>>(
      path,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': 'application/pdf'},
      ),
    );
    _check(response, path);
    final dir = await getTemporaryDirectory();
    final kind = certificate.winner ? 'ganador' : 'participacion';
    final file = File('${dir.path}/certificado-$kind-${certificate.id.substring(0, 8)}.pdf');
    return file.writeAsBytes(response.data ?? const [], flush: true);
  }

  void _check(Response<dynamic> response, String path) {
    final status = response.statusCode ?? 500;
    if (status >= 400) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}

final certificatesRepositoryProvider = Provider<CertificatesRepository>(
  (ref) => CertificatesRepository(ref.watch(apiClientProvider)),
);

final myCertificatesProvider =
    FutureProvider.autoDispose<List<MyCertificate>>((ref) {
  return ref.watch(certificatesRepositoryProvider).mine();
});
