part of 'auth_controller.dart';

/// Perfil propio: foto, datos y contraseña.
extension AuthProfile on AuthController {
  /// Cambia la foto de perfil: sube la imagen, la enlaza al usuario y
  /// refresca el estado de sesión para que toda la app la vea al instante.
  Future<bool> changeAvatar(File file) async {
    patch(currentState.copyWith(submitting: true, clearError: true));
    final res = await _ref.read(updateAvatarUseCaseProvider)(file);
    return res.when(
      success: (user) {
        patch(currentState.copyWith(submitting: false, user: user));
        return true;
      },
      failure: (f) {
        patch(currentState.copyWith(submitting: false, errorMessage: f.message));
        return false;
      },
    );
  }

  /// Guarda los campos editados del perfil propio.
  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    patch(currentState.copyWith(submitting: true, clearError: true));
    final res = await _ref.read(updateProfileUseCaseProvider)(fields);
    return res.when(
      success: (user) {
        patch(currentState.copyWith(submitting: false, user: user));
        return true;
      },
      failure: (f) {
        patch(currentState.copyWith(submitting: false, errorMessage: f.message));
        return false;
      },
    );
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    patch(currentState.copyWith(submitting: true, clearError: true));
    final res = await _ref.read(changePasswordUseCaseProvider)(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    return res.when(
      success: (_) {
        patch(currentState.copyWith(submitting: false, mustChangePassword: false));
        return true;
      },
      failure: (f) {
        patch(currentState.copyWith(submitting: false, errorMessage: f.message));
        return false;
      },
    );
  }
}
