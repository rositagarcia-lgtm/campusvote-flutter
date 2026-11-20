/// Usuario autenticado (entidad de dominio).
class AuthUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? organizationId;
  final String? avatarUrl;

  /// El backend lo envía en `/me` y en las respuestas de acceso. Sin
  /// persistirlo, reabrir la app perdía la obligación de cambiar la clave
  /// temporal y el router dejaba de exigirla.
  final bool mustChangePassword;

  const AuthUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.organizationId,
    this.avatarUrl,
    this.mustChangePassword = false,
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
    String? avatarUrl,
    bool? mustChangePassword,
  }) {
    return AuthUser(
      id: id,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}
