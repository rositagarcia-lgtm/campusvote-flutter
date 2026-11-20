import 'package:campusvote_flutter/core/network/api_client.dart';
import 'package:campusvote_flutter/core/storage/secure_storage.dart';
import 'package:campusvote_flutter/features/teacher_results/data/adviser_projects_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _PagedApiClient extends ApiClient {
  _PagedApiClient() : super(storage: SecureStorage());

  final pages = <int>[];

  @override
  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic>? query}) async {
    final page = query?['page'] as int? ?? 1;
    pages.add(page);
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {
        'data': [
          {'id': 'p-$page', 'name': 'Proyecto $page', 'status': 'DRAFT'},
        ],
        'meta': {
          'pagination': {
            'page': page,
            'limit': 50,
            'total': 51,
            'totalPages': 2
          },
        },
      },
    );
  }
}

void main() {
  test('el docente ve todos sus proyectos asesorados, no solo 50', () async {
    final api = _PagedApiClient();
    final projects = await AdviserProjectsRepository(api).mine();

    expect(api.pages, [1, 2]);
    expect(projects.map((p) => p.id), ['p-1', 'p-2']);
  });
}
