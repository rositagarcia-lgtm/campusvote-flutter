import '../../domain/entities/fair_assignment.dart';

/// Contrato REAL de `GET /api/fairs/my-assignments` (rol=JURY).
/// `{ assigned_at, fair: {id, organization_id, name, description, status, starts_at, ends_at} }`
/// Más el envelope paginado `{ data: [...], pagination: { page, limit, total } }`.
class FairAssignmentListModel {
  final List<Map<String, dynamic>> itemsRaw;
  final int total;
  final int page;
  final int limit;

  const FairAssignmentListModel({
    required this.itemsRaw,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory FairAssignmentListModel.fromResponse({
    required dynamic data,
    required Map<String, dynamic>? meta,
  }) {
    // Tipado explícito: con `final list` el tipo era dynamic, y
    // whereType/map devolvían List<dynamic>, que falla al asignarse a una
    // lista tipada ("List<dynamic> is not a subtype of ...").
    final List<dynamic> list = (data is List)
        ? data
        : (data is Map && data['data'] is List
            ? data['data']
            : const <dynamic>[]);
    final pagination = meta?['pagination'] is Map
        ? Map<String, dynamic>.from(meta!['pagination'] as Map)
        : <String, dynamic>{};
    return FairAssignmentListModel(
      itemsRaw: list
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList(),
      total: (pagination['total'] ?? list.length) as int,
      page: (pagination['page'] ?? 1) as int,
      limit: (pagination['limit'] ?? 10) as int,
    );
  }
}

class FairAssignmentModel extends FairAssignment {
  const FairAssignmentModel({
    required super.fairId,
    required super.organizationId,
    required super.name,
    required super.description,
    required super.status,
    super.startsAt,
    super.endsAt,
    super.assignedAt,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  factory FairAssignmentModel.fromJson(Map<String, dynamic> json) {
    final fair = (json['fair'] is Map)
        ? Map<String, dynamic>.from(json['fair'] as Map)
        : json;
    return FairAssignmentModel(
      fairId: (fair['id'] ?? '').toString(),
      organizationId: (fair['organization_id'] ?? fair['organizationId'] ?? '')
          .toString(),
      name: (fair['name'] ?? '').toString(),
      description: (fair['description'] ?? '').toString(),
      status: parseFairAssignmentStatus(fair['status']?.toString()),
      startsAt: _parseDate(fair['starts_at'] ?? fair['startsAt']),
      endsAt: _parseDate(fair['ends_at'] ?? fair['endsAt']),
      assignedAt: _parseDate(json['assigned_at'] ?? json['assignedAt']),
    );
  }

  FairAssignment toEntity() => this;
}