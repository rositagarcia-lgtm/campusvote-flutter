import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';
import '../entities/login_result.dart';
import '../entities/totp.dart';

abstract class AuthRepository {
  Future<Result<LoginResult>> login({
    required String email,
    required String password,
  });

  Future<Result<LoginResult>> verifyLoginTotp({
    required String tempToken,
    required String code,
  });

  Future<Result<TokenPair>> refresh({required String refreshToken});

  Future<Result<AuthUser>> getProfile();

  Future<void> logout({String? refreshToken});

  Future<AuthUser?> currentUser();

  Future<bool> hasSession();

  Future<void> persistSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  });

  Future<void> persistUser(AuthUser user);

  Future<void> clearSession();

  Future<String?> currentAccessToken();
  Future<String?> currentRefreshToken();

  /// 2FA / TOTP
  Future<Result<TotpStatus>> getTwoFactorStatus();

  Future<Result<TotpSetup>> setupTotp();

  Future<Result<TotpEnableResult>> verifyAndEnableTotp(String code);

  Future<Result<void>> disableTotp({required String password});

  /// Cambio de contraseña del usuario autenticado.
  Future<Result<void>> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  });
}