import '../../domain/entities/candidate_list.dart';

class CandidateListModel extends CandidateList {
  const CandidateListModel({
    required super.id,
    required super.name,
    super.acronym,
    super.motto,
    super.logoUrl,
    super.imageUrl,
    super.description,
    super.category,
    super.tags,
  });

  static String _str(dynamic v) => (v ?? '').toString();

  factory CandidateListModel.fromJson(Map<String, dynamic> json) {
    return CandidateListModel(
      id: _str(json['id']),
      name: _str(json['name']),
      acronym: json['acronym']?.toString(),
      motto: json['motto']?.toString(),
      logoUrl: (json['logo'] ?? json['logoUrl'])?.toString(),
      imageUrl: (json['imageUrl'] ?? json['image_url'])?.toString(),
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      tags: (json['tags'] is List)
          ? (json['tags'] as List).map((e) => e.toString()).toList()
          : const [],
    );
  }

  CandidateList toEntity() => this;
}

class CandidateModel extends Candidate {
  const CandidateModel({
    required super.id,
    required super.userId,
    required super.fullName,
    super.positionId,
    required super.orderIndex,
    super.isPrincipal,
    super.photoUrl,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};
    // El backend envía `user.firstName` snake_case: leer ambos formatos.
    final firstName = (user['first_name'] ?? user['firstName'])?.toString();
    final lastName = (user['last_name'] ?? user['lastName'])?.toString();
    final composed =
        ('${firstName ?? ''} ${lastName ?? ''}').trim();

    return CandidateModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? user['id'] ?? '')
          .toString(),
      fullName: composed.isNotEmpty
          ? composed
          : (user['email'] ?? json['email'] ?? 'Candidato').toString(),
      positionId:
          (json['positionId'] ?? json['position_id'])?.toString(),
      orderIndex: (json['orderIndex'] ?? json['order_index'] ?? 1) is int
          ? (json['orderIndex'] ?? json['order_index'] ?? 1) as int
          : 1,
      isPrincipal: (json['isPrincipal'] ?? json['is_principal'] ?? true) as bool,
      photoUrl: (user['photoUrl'] ?? user['photo_url'])?.toString(),
    );
  }

  Candidate toEntity() => this;
}