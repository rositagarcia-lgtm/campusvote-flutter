import '../../domain/entities/election_position.dart';

class ElectionPositionModel extends ElectionPosition {
  const ElectionPositionModel({
    required super.id,
    required super.name,
    super.description,
    required super.seats,
  });

  factory ElectionPositionModel.fromJson(Map<String, dynamic> json) {
    return ElectionPositionModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      seats: (json['seats'] ?? 1) as int,
    );
  }

  ElectionPosition toEntity() => this;
}