import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/state/auth_controller.dart';
import '../domain/published_results.dart';

/// Resultados publicados (feria cerrada y publicada por el admin). Los ve
/// toda la comunidad: el detalle de votos y rúbricas queda en la web.
class PublishedResultsRepository {
  PublishedResultsRepository(this._client);
  final ApiClient _client;

  Future<List<PublishedFair>> fairs() async {
    final data = await _get(ApiEndpoints.publishedResults);
    return [
      for (final f in data is List ? data : const [])
        if (f is Map) PublishedFair.fromJson(Map<String, dynamic>.from(f)),
    ];
  }

  Future<PublishedResults> results(String fairId) async {
    final data = await _get(ApiEndpoints.resultsPodium(fairId));
    if (data is! Map) throw const FormatException('Resultados no válidos.');
    return PublishedResults.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Object?> _get(String path) async {
    final response = await _client.get(path);
    if ((response.statusCode ?? 500) >= 400) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    final body = response.data;
    return body is Map ? body['data'] : body;
  }
}

final publishedResultsRepositoryProvider =
    Provider<PublishedResultsRepository>(
  (ref) => PublishedResultsRepository(ref.watch(apiClientProvider)),
);

/// Ferias con resultados publicados que el usuario puede ver.
final publishedFairsProvider =
    FutureProvider.autoDispose<List<PublishedFair>>((ref) async {
  final signedIn =
      ref.watch(authControllerProvider.select((s) => s.authenticated));
  if (!signedIn) return const [];
  return ref.watch(publishedResultsRepositoryProvider).fairs();
});

final publishedResultsProvider = FutureProvider.autoDispose
    .family<PublishedResults, String>((ref, fairId) {
  return ref.watch(publishedResultsRepositoryProvider).results(fairId);
});
