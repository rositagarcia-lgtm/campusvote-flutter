/// Lista candidata con sus miembros.
class CandidateList {
  final String id;
  final String name;
  final String? acronym;
  final String? motto;
  final String? logoUrl;
  final String? imageUrl;
  final String? description;
  final String? category;
  final List<String> tags;

  const CandidateList({
    required this.id,
    required this.name,
    this.acronym,
    this.motto,
    this.logoUrl,
    this.imageUrl,
    this.description,
    this.category,
    this.tags = const [],
  });
}

/// Un candidato (persona) dentro de una lista.
class Candidate {
  final String id; // candidacyId
  final String userId;
  final String fullName;
  final String? positionId;
  final int orderIndex;
  final bool isPrincipal;
  final String? photoUrl;

  const Candidate({
    required this.id,
    required this.userId,
    required this.fullName,
    this.positionId,
    required this.orderIndex,
    this.isPrincipal = true,
    this.photoUrl,
  });
}