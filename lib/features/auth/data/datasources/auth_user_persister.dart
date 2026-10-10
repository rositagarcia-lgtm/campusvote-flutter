import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/auth_user.dart';
import '../repositories/auth_repository_impl.dart';

class SharedPrefsAuthUserPersister implements AuthUserPersister {
  SharedPrefsAuthUserPersister(this._storage);
  final LocalStorage _storage;

  static const _key = 'cv.auth_user';

  @override
  Future<void> persistUser(AuthUser user) async {
    await _storage.setString(
        _key,
        jsonEncode({
          'id': user.id,
          'email': user.email,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'role': user.role,
          'organizationId': user.organizationId,
          // Sin esto la foto de perfil se perdía al reabrir la app aunque el
          // servidor sí la tuviera guardada.
          'avatarUrl': user.avatarUrl,
        }));
  }

  @override
  Future<AuthUser?> readUser() async {
    final raw = _storage.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUser(
        id: map['id']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        firstName: map['firstName'] as String?,
        lastName: map['lastName'] as String?,
        role: map['role'] as String?,
        organizationId: map['organizationId'] as String?,
        avatarUrl: map['avatarUrl'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _storage.remove(_key);
  }
}
