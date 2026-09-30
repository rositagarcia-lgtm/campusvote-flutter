import 'dart:io';

import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';
import '../entities/login_result.dart';
import '../entities/totp.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<LoginResult>> call({
    required String email,
    required String password,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      return Future.value(const FailureResult(
        ValidationFailure(message: 'El correo es obligatorio'),
      ));
    }
    if (password.isEmpty) {
      return Future.value(const FailureResult(
        ValidationFailure(message: 'La contraseña es obligatoria'),
      ));
    }
    return _repo.login(email: cleanEmail, password: password);
  }
}

class VerifyLoginTotpUseCase {
  VerifyLoginTotpUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<LoginResult>> call({
    required String tempToken,
    required String code,
  }) {
    if (code.trim().length != 6) {
      return Future.value(const FailureResult(
        ValidationFailure(
          message: 'El código TOTP debe tener 6 dígitos',
        ),
      ));
    }
    return _repo.verifyLoginTotp(tempToken: tempToken, code: code.trim());
  }
}

/// Solicita el código OTP del acceso sin contraseña.
class RequestEmailLoginUseCase {
  RequestEmailLoginUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<LoginResult>> call({required String email}) {
    final clean = email.trim().toLowerCase();
    if (clean.isEmpty) {
      return Future.value(const FailureResult(
        ValidationFailure(message: 'El correo es obligatorio'),
      ));
    }
    if (!_isEmail(clean)) {
      return Future.value(const FailureResult(
        ValidationFailure(message: 'Escribe un correo válido'),
      ));
    }
    return _repo.requestEmailLogin(email: clean);
  }
}

/// Verifica el código OTP enviado al correo (paso 2 del acceso sin contraseña).
class VerifyEmailLoginUseCase {
  VerifyEmailLoginUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<LoginResult>> call({
    required String tempToken,
    required String code,
  }) {
    if (code.trim().length != 6 || !RegExp(r'^\d{6}$').hasMatch(code.trim())) {
      return Future.value(const FailureResult(
        ValidationFailure(
          message: 'El código debe tener 6 dígitos',
        ),
      ));
    }
    return _repo.verifyEmailLogin(tempToken: tempToken, code: code.trim());
  }
}

class RefreshTokenUseCase {
  RefreshTokenUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<TokenPair>> call(String refreshToken) =>
      _repo.refresh(refreshToken: refreshToken);
}

class GetProfileUseCase {
  GetProfileUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<AuthUser>> call() => _repo.getProfile();
}

class LogoutUseCase {
  LogoutUseCase(this._repo);
  final AuthRepository _repo;
  Future<void> call() => _repo.logout();
}

class ChangePasswordUseCase {
  ChangePasswordUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call({
    required String currentPassword,
    required String newPassword,
  }) {
    if (currentPassword.length < 8) {
      return Future.value(const FailureResult(ValidationFailure(
        message: 'La contraseña actual debe tener al menos 8 caracteres',
      )));
    }
    final passwordError = _validatePassword(newPassword);
    if (passwordError != null) {
      return Future.value(FailureResult(
        ValidationFailure(message: passwordError),
      ));
    }
    return _repo.changeMyPassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// Política de contraseñas del backend: 8-72 chars, mayúscula, minúscula,
  /// dígito y al menos un carácter especial.
  String? _validatePassword(String p) {
    if (p.length < 8) return 'La contraseña debe tener mínimo 8 caracteres';
    if (p.length > 72) return 'La contraseña debe tener máximo 72 caracteres';
    if (!RegExp(r'[a-z]').hasMatch(p)) {
      return 'Debe incluir al menos una letra minúscula';
    }
    if (!RegExp(r'[A-Z]').hasMatch(p)) {
      return 'Debe incluir al menos una letra mayúscula';
    }
    if (!RegExp(r'\d').hasMatch(p)) {
      return 'Debe incluir al menos un número';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(p)) {
      return 'Debe incluir al menos un carácter especial';
    }
    return null;
  }
}

class GetTwoFactorStatusUseCase {
  GetTwoFactorStatusUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<TotpStatus>> call() => _repo.getTwoFactorStatus();
}

class SetupTotpUseCase {
  SetupTotpUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<TotpSetup>> call() => _repo.setupTotp();
}

class VerifyAndEnableTotpUseCase {
  VerifyAndEnableTotpUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<TotpEnableResult>> call(String code) {
    if (code.trim().length != 6) {
      return Future.value(const FailureResult(ValidationFailure(
        message: 'El código debe tener 6 dígitos',
      )));
    }
    return _repo.verifyAndEnableTotp(code.trim());
  }
}

class DisableTotpUseCase {
  DisableTotpUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call({required String password}) {
    if (password.isEmpty) {
      return Future.value(const FailureResult(
        ValidationFailure(message: 'La contraseña es obligatoria para deshabilitar 2FA'),
      ));
    }
    return _repo.disableTotp(password: password);
  }
}

/// Cambia la foto de perfil: sube la imagen y la enlaza al usuario.
class UpdateAvatarUseCase {
  UpdateAvatarUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthUser>> call(File file) {
    if (!file.existsSync()) {
      return Future.value(const FailureResult(
        ValidationFailure(message: 'No se encontró la imagen seleccionada'),
      ));
    }
    return _repo.updateAvatar(file);
  }
}

/// Actualiza los datos del perfil propio.
class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthUser>> call(Map<String, dynamic> fields) {
    if (fields.isEmpty) {
      return Future.value(const FailureResult(
        ValidationFailure(message: 'No hay cambios para guardar'),
      ));
    }
    return _repo.updateProfile(fields);
  }
}

bool _isEmail(String value) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);