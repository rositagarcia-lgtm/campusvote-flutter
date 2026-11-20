part of 'auth_session_datasource.dart';

/// Persistencia local de la sesión y tokens.
extension AuthSessionStore on AuthSessionDataSource {
  Future<AuthUser?> currentUser() => _persister.readUser();

  Future<bool> hasSession() async {
    try {
      final refresh = await _client.storage.readRefreshToken();
      if (refresh != null && refresh.trim().isNotEmpty) {
        return true;
      }
    } catch (_) {
      // Si el almacenamiento seguro falla al leer, se purga la sesión local.
    }
    await clearSession();
    return false;
  }

  Future<void> persistSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _persister.persistUser(user);
    await _client.storage.writeRefreshToken(refreshToken.trim());
    await _client.storage.writeAccessToken(accessToken.trim());
  }

  Future<void> persistUser(AuthUser user) async {
    await _persister.persistUser(user);
  }

  Future<void> clearSession() async {
    try {
      await _client.storage.clearAll();
    } catch (_) {
      // No impedir la limpieza del perfil local si falla el keystore.
    }
    try {
      await _persister.clearUser();
    } catch (_) {}
  }

  Future<String?> currentAccessToken() => _client.storage.readAccessToken();
  Future<String?> currentRefreshToken() => _client.storage.readRefreshToken();
}