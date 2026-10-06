part of 'auth_session_datasource.dart';

/// Persistencia local de la sesión y tokens.
extension AuthSessionStore on AuthSessionDataSource {
  Future<AuthUser?> currentUser() => _persister.readUser();

  Future<bool> hasSession() async {
    final token = await _client.storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> persistSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _persister.persistUser(user);
    await _client.storage.writeAccessToken(accessToken);
    await _client.storage.writeRefreshToken(refreshToken);
  }

  Future<void> persistUser(AuthUser user) async {
    await _persister.persistUser(user);
  }

  Future<void> clearSession() async {
    await _client.storage.clearAll();
    await _persister.clearUser();
  }

  Future<String?> currentAccessToken() => _client.storage.readAccessToken();
  Future<String?> currentRefreshToken() => _client.storage.readRefreshToken();
}
