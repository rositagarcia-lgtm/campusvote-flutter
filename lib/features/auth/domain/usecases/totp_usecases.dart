import 'dart:io';

import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';
import '../entities/totp.dart';
import '../repositories/auth_repository.dart';
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

  Future<Result<void>> call({
    required String password,
    required String code,
  }) {
    if (password.isEmpty) {
      return Future.value(const FailureResult(
        ValidationFailure(
            message: 'La contraseña es obligatoria para deshabilitar 2FA'),
      ));
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code.trim())) {
      return Future.value(const FailureResult(
        ValidationFailure(message: 'El código TOTP debe tener 6 dígitos'),
      ));
    }
    return _repo.disableTotp(password: password, code: code.trim());
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

