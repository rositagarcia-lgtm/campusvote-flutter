import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/constants.dart';

/// Abstracción de almacenamiento seguro para tokens.
///
/// La UI nunca debe acceder directamente al storage.
class SecureStorage {
  SecureStorage({FlutterSecureStorage? backend})
      : _storage = backend ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  Future<void> writeAccessToken(String token) =>
      _storage.write(key: AppConstants.secureAccessToken, value: token);

  Future<String?> readAccessToken() =>
      _storage.read(key: AppConstants.secureAccessToken);

  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: AppConstants.secureRefreshToken, value: token);

  Future<String?> readRefreshToken() =>
      _storage.read(key: AppConstants.secureRefreshToken);

  Future<void> clearAll() => _storage.deleteAll();
}
