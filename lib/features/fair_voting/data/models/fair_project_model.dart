import '../../domain/entities/fair_project.dart';

class FairProjectMemberModel extends FairProjectMember {
  const FairProjectMemberModel({
    required super.id,
    required super.userId,
    required super.fullName,
    required super.role,
    super.institutionalId,
  });

  factory FairProjectMemberModel.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] is Map)
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};
    final first =
        (user['first_name'] ?? user['firstName'])?.toString() ?? '';
    final last =
        (user['last_name'] ?? user['lastName'])?.toString() ?? '';
    final composed = ('$first $last').trim();
    return FairProjectMemberModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? user['id'] ?? '')
          .toString(),
      fullName: composed.isNotEmpty
          ? composed
          : (user['email']?.toString() ?? 'Miembro'),
      role: (json['role'] ?? 'EXPOSITOR').toString(),
      institutionalId:
          (user['institutional_id'] ?? user['institutionalId'])?.toString(),
    );
  }

  FairProjectMember toEntity() => this;
}

class FairProjectModel extends FairProject {
  const FairProjectModel({
    required super.id,
    required super.fairId,
    super.organizationId,
    required super.name,
    required super.description,
    super.logoUrl,
    super.coverUrl,
    super.projectUrl,
    required super.status,
    super.categoryId,
    super.standId,
    super.reviewedAt,
    super.submittedAt,
    super.members,
    super.categoryName,
    super.standCode,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  factory FairProjectModel.fromJson(Map<String, dynamic> json) {
    final membersRaw = json['members'];
    final members = <FairProjectMember>[];
    if (membersRaw is List) {
      for (final m in membersRaw.whereType<Map>()) {
        members.add(FairProjectMemberModel.fromJson(
          Map<String, dynamic>.from(m),
        ));
      }
    }

    final category = json['category'];
    final stand = json['stand'];

    return FairProjectModel(
      id: (json['id'] ?? '').toString(),
      fairId: (json['fair_id'] ?? json['fairId'] ?? '').toString(),
      organizationId:
          (json['organization_id'] ?? json['organizationId'])?.toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      logoUrl: (json['logo_url'] ?? json['logoUrl'])?.toString(),
      coverUrl: (json['cover_url'] ?? json['coverUrl'])?.toString(),
      projectUrl: (json['project_url'] ?? json['projectUrl'])?.toString(),
      status: parseFairProjectStatus(json['status']?.toString()),
      categoryId: (json['category_id'] ?? json['categoryId'])?.toString(),
      standId: (json['stand_id'] ?? json['standId'])?.toString(),
      reviewedAt: _parseDate(json['reviewed_at'] ?? json['reviewedAt']),
      submittedAt: _parseDate(json['submitted_at'] ?? json['submittedAt']),
      members: members,
      categoryName: category is Map ? (category['name']?.toString()) : null,
      standCode: stand is Map ? (stand['code']?.toString()) : null,
    );
  }

  FairProject toEntity() => this;
}

class FairProjectListModel {
  final List<FairProjectModel> items;
  final int total;
  final int page;
  final int limit;

  const FairProjectListModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory FairProjectListModel.fromResponse({
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
    final items = list
        .whereType<Map>()
        .map((m) => FairProjectModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    return FairProjectListModel(
      items: items,
      total: (pagination['total'] ?? items.length) as int,
      page: (pagination['page'] ?? 1) as int,
      limit: (pagination['limit'] ?? 20) as int,
    );
  }
}