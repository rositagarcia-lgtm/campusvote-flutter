import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/network/api_client.dart';
import '../../auth/domain/entities/auth_role.dart';
import '../../auth/presentation/state/auth_controller.dart';

/// Proyecto que el docente inscribió como asesor (`GET /projects/assisted/mine`).
class AdvisedProject {
  final String id;
  final String name;
  final String status;
  final String? fairName;
  final bool fairOpen;
  final String? category;
  final String? stand;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String? videoUrl;
  final List<String> imageUrls;
  final List<String> team;

  const AdvisedProject({
    required this.id,
    required this.name,
    required this.status,
    this.fairName,
    this.fairOpen = false,
    this.category,
    this.stand,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.videoUrl,
    this.imageUrls = const [],
    this.team = const [],
  });

  factory AdvisedProject.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> map(Object? v) =>
        v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
    String? text(Object? v) {
      final t = v?.toString().trim() ?? '';
      return t.isEmpty ? null : t;
    }

    final fair = map(json['fair']);
    return AdvisedProject(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      status: '${json['status'] ?? ''}',
      fairName: text(fair['name']),
      fairOpen: fair['status'] == 'OPEN',
      category: text(map(json['category'])['name']),
      stand: text(map(json['stand'])['code']),
      description: text(json['description']),
      logoUrl: text(json['logo_url']),
      coverUrl: text(json['cover_url']) ?? text(json['logo_url']),
      videoUrl: text(json['video_url']),
      imageUrls: [
        for (final url in json['image_urls'] is List ? json['image_urls'] as List : const [])
          if (text(url) case final src?) src,
      ],
      team: [
        for (final m
            in json['members'] is List ? json['members'] as List : const [])
          if (m is Map)
            [
              map(m['user'])['first_name'],
              map(m['user'])['last_name'],
            ].whereType<String>().join(' ').trim(),
      ].where((name) => name.isNotEmpty).toList(),
    );
  }

  /// Etiqueta y si requiere acción del alumno o del comité.
  (String, bool) get statusLabel => switch (status) {
        'DRAFT_PENDING_STUDENT_CONFIRMATION' => (
            'Espera que el alumno confirme',
            true
          ),
        'DRAFT' => ('Borrador', true),
        'SUBMITTED' => ('En revisión del comité', false),
        'APPROVED' => ('Aprobado', false),
        'REJECTED' => ('Observado', true),
        _ => (status, false),
      };
}

class AdviserProjectsRepository {
  AdviserProjectsRepository(this._client);
  final ApiClient _client;

  static const _path = '/api/projects/assisted/mine';

  Future<List<AdvisedProject>> mine() async {
    final response = await _client.get(_path, query: {'limit': 50});
    if ((response.statusCode ?? 500) >= 400) {
      throw DioException(
        requestOptions: RequestOptions(path: _path),
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    final body = response.data;
    final data = body is Map ? body['data'] : body;
    return [
      for (final p in data is List ? data : const [])
        if (p is Map) AdvisedProject.fromJson(Map<String, dynamic>.from(p)),
    ];
  }
}

final adviserProjectsRepositoryProvider = Provider<AdviserProjectsRepository>(
  (ref) => AdviserProjectsRepository(ref.watch(apiClientProvider)),
);

/// Proyectos que asesora el docente en sesión.
final adviserProjectsProvider =
    FutureProvider.autoDispose<List<AdvisedProject>>((ref) async {
  final isTeacher = ref.watch(authControllerProvider
      .select((s) => s.authenticated && s.user?.role == AuthRole.teacher));
  if (!isTeacher) return const [];
  return ref.watch(adviserProjectsRepositoryProvider).mine();
});
