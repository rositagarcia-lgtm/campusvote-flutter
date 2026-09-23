import '../../domain/entities/election.dart';

/// El backend responde con campos Prisma en camelCase para elecciones.
/// Mantenemos fallback snake_case como tolerancia.
class ElectionModel extends Election {
  const ElectionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.processType,
    required super.scopeType,
    required super.status,
    required super.startAt,
    required super.endAt,
    required super.organizationId,
    super.organizationName,
    super.organizationLogo,
    super.periodId,
    super.facultyId,
    super.programId,
    super.isAnonymousAllowed,
  });

  static String _str(dynamic v, [String fallback = '']) =>
      v == null ? fallback : v.toString();

  static DateTime _parseDate(dynamic v, DateTime fallback) {
    if (v is String && v.isNotEmpty) {
      final dt = DateTime.tryParse(v);
      if (dt != null) return dt;
    }
    return fallback;
  }

  factory ElectionModel.fromJson(Map<String, dynamic> json) {
    final start = _parseDate(json['startAt'] ?? json['start_at'], DateTime.now());
    final end = _parseDate(json['endAt'] ?? json['end_at'], DateTime.now());

    return ElectionModel(
      id: _str(json['id']),
      title: _str(json['title']),
      description: _str(json['description']),
      processType: _str(json['processType'] ?? json['process_type'], 'VOTE'),
      scopeType: _str(
        json['scopeType'] ?? json['scope_type'] ?? json['election_type'],
        'UNIVERSITY',
      ),
      status: _str(json['status'], 'DRAFT'),
      startAt: start,
      endAt: end,
      organizationId: _str(
        json['organizationId'] ??
            json['organization_id'] ??
            (json['organization'] is Map
                ? (json['organization'] as Map)['id']
                : null),
      ),
      organizationName:
          (json['organization'] is Map
                  ? (json['organization'] as Map)['name']
                  : null)
              ?.toString() ??
              json['organizationName'] as String?,
      organizationLogo:
          (json['organization'] is Map
                  ? (json['organization'] as Map)['logo']
                  : null)
              ?.toString() ??
              json['organizationLogo'] as String?,
      periodId: (json['periodId'] ?? json['period_id'])?.toString(),
      facultyId: (json['facultyId'] ?? json['faculty_id'])?.toString(),
      programId: (json['programId'] ?? json['program_id'])?.toString(),
      isAnonymousAllowed:
          (json['isAnonymousAllowed'] ?? json['is_anonymous_allowed']) == true,
    );
  }

  Election toEntity() => Election(
        id: id,
        title: title,
        description: description,
        processType: processType,
        scopeType: scopeType,
        status: status,
        startAt: startAt,
        endAt: endAt,
        organizationId: organizationId,
        organizationName: organizationName,
        organizationLogo: organizationLogo,
        periodId: periodId,
        facultyId: facultyId,
        programId: programId,
        isAnonymousAllowed: isAnonymousAllowed,
      );
}

class ElectionListModel {
  final List<ElectionModel> items;
  final int total;
  final int page;
  final int totalPages;
  const ElectionListModel({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  /// `data` puede ser la lista (así responde GET /api/elections) o un objeto
  /// con `items` / `elections`.
  factory ElectionListModel.fromResponse(
    dynamic data,
    Map<String, dynamic>? meta,
  ) {
    // Tipado explícito: con `final list` el tipo era dynamic, y
    // whereType/map devolvían List<dynamic>, que falla al asignarse a una
    // lista tipada ("List<dynamic> is not a subtype of ...").
    final List<dynamic> list = (data is List)
        ? data
        : (data is Map && data['items'] is List
            ? data['items'] as List
            : (data is Map && data['elections'] is List
                ? data['elections'] as List
                : const <dynamic>[]));
    final items = list
        .whereType<Map>()
        .map((e) => ElectionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final pagination = meta?['pagination'] is Map
        ? Map<String, dynamic>.from(meta!['pagination'] as Map)
        : <String, dynamic>{};
    return ElectionListModel(
      items: items,
      total: (pagination['total'] ?? items.length) as int,
      page: (pagination['page'] ?? 1) as int,
      totalPages: (pagination['totalPages'] ?? 1) as int,
    );
  }
}