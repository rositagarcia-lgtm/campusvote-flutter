import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/endpoints.dart';
import '../di/core_providers.dart';
import '../errors/error_mapper.dart';
import '../errors/result.dart';
import '../network/api_client.dart';
import '../network/api_response.dart';
import 'organization_branding.dart';

/// Resuelve el branding institucional desde la API.
///
/// El login ya trae la organización, pero al reabrir la app la sesión se
/// restaura desde local storage y solo conserva el `organizationId`: sin esta
/// llamada el panel arranca con la marca `CampusVote` en vez de la/logo real.
class OrganizationBrandingRepository {
  OrganizationBrandingRepository(this._client);

  final ApiClient _client;

  Future<Result<OrganizationBranding>> fetch(String organizationId) async {
    try {
      final res =
          await _client.get(ApiEndpoints.organizationById(organizationId));
      final raw = res.data;
      if (raw is! Map) {
        return const FailureResult(UnknownFailure(
          message: 'Respuesta inválida al consultar la organización',
        ));
      }
      final body = Map<String, dynamic>.from(raw);
      final r = ApiResponse<Map<String, dynamic>>.fromJson(
        body,
        (d) => d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{},
      );
      final data = r.data;
      if (!r.success || data == null || !data.containsKey('id')) {
        return FailureResult(UnknownFailure(
          message: r.error?.message ??
              r.message ??
              'No se pudo cargar la organización',
          code: r.error?.code,
        ));
      }
      return Success(OrganizationBranding.fromOrganizationJson(data));
    } catch (e) {
      return FailureResult(mapExceptionToFailure(e));
    }
  }
}

final organizationBrandingRepositoryProvider =
    Provider<OrganizationBrandingRepository>((ref) {
  return OrganizationBrandingRepository(ref.watch(apiClientProvider));
});
