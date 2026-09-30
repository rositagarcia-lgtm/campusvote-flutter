import '../../domain/entities/auth_user.dart';

/// El backend usa snake_case para usuarios via `formatUserResponse.js`.
/// Mantenemos fallback camelCase por compatibilidad con versiones previas.
class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    super.firstName,
    super.lastName,
    super.role,
    super.organizationId,
    super.avatarUrl,
  });

  static String _str(dynamic v) => (v ?? '').toString();

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final avatar = json['avatar_url'] as String? ?? json['avatarUrl'] as String?;
    return AuthUserModel(
      id: _str(json['id'] ?? json['userId']),
      email: _str(json['email']),
      firstName: json['first_name'] as String? ?? json['firstName'] as String?,
      lastName: json['last_name'] as String? ?? json['lastName'] as String?,
      role: json['role'] as String?,
      organizationId: json['organization_id'] as String? ??
          json['organizationId'] as String?,
      avatarUrl: (avatar == null || avatar.isEmpty) ? null : avatar,
    );
  }

  factory AuthUserModel.fromEntity(AuthUser u) => AuthUserModel(
        id: u.id,
        email: u.email,
        firstName: u.firstName,
        lastName: u.lastName,
        role: u.role,
        organizationId: u.organizationId,
        avatarUrl: u.avatarUrl,
      );

  AuthUser toEntity() => AuthUser(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        organizationId: organizationId,
        avatarUrl: avatarUrl,
      );
}