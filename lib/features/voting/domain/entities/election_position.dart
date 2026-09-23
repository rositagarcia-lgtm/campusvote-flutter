/// Cargo dentro de una elección (Presidente, Representante, etc.).
class ElectionPosition {
  final String id;
  final String name;
  final String? description;
  final int seats;

  const ElectionPosition({
    required this.id,
    required this.name,
    this.description,
    required this.seats,
  });

  bool get isMultiSeat => seats > 1;
}