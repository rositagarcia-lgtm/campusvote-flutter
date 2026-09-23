/// Usuario autenticado (entidad de dominio).
class AuthUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? organizationId;

  const AuthUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.organizationId,
  });

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    return email;
  }

  AuthUser copyWith({
    String? firstName,
    String? lastName,
    String? role,
    String? organizationId,
  }) {
    return AuthUser(
      id: id,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
    );
  }
}