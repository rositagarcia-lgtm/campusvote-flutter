import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/branding/organization_branding.dart';
import '../../domain/entities/auth_user.dart';
import 'auth_events.dart';
import 'auth_providers.dart';

class AuthState {
  final bool initializing;
  final bool authenticated;
  final AuthUser? user;
  final bool submitting;
  final String? tempToken; // para 2FA / EMAIL_PENDING
  final bool requiresEmailOtp; // acceso sin contraseña (email + código)
  final String? pendingEmail; // correo del flujo OTP en curso
  final String? errorMessage;
  final bool mustChangePassword;

  const AuthState({
    this.initializing = true,
    this.authenticated = false,
    this.user,
    this.submitting = false,
    this.tempToken,
    this.requiresEmailOtp = false,
    this.pendingEmail,
    this.errorMessage,
    this.mustChangePassword = false,
  });

  AuthState copyWith({
    bool? initializing,
    bool? authenticated,
    AuthUser? user,
    bool? submitting,
    String? tempToken,
    bool? requiresEmailOtp,
    String? pendingEmail,
    String? errorMessage,
    bool? mustChangePassword,
    bool clearTempToken = false,
    bool clearError = false,
  }) {
    return AuthState(
      initializing: initializing ?? this.initializing,
      authenticated: authenticated ?? this.authenticated,
      user: user ?? this.user,
      submitting: submitting ?? this.submitting,
      tempToken: clearTempToken ? null : (tempToken ?? this.tempToken),
      requiresEmailOtp: requiresEmailOtp ?? this.requiresEmailOtp,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState()) {
    _bootstrap();
    // Escucha logout forzado (401 → refresh fallido).
    _ref.listen<AuthEvents?>(authEventsProvider, (prev, next) {
      if (next != null && prev != null && next.logoutCount > prev.logoutCount) {
        state = const AuthState(initializing: false, authenticated: false);
      }
    });
  }

  final Ref _ref;

  Future<void> _bootstrap() async {
    try {
      final repo = _ref.read(authRepositoryProvider);
      final hasSession = await repo.hasSession();
      if (!hasSession) {
        state = state.copyWith(initializing: false, authenticated: false);
        return;
      }
      final user = await repo.currentUser();
      if (user != null) {
        state = state.copyWith(
          initializing: false,
          authenticated: true,
          user: user,
        );
      } else {
        state = state.copyWith(initializing: false, authenticated: false);
      }
    } catch (_) {
      // Si leer la sesión falla —almacenamiento bloqueado, plugin no
      // disponible en esta plataforma— se manda al login. Sin esto la
      // excepción dejaba `initializing` en true y la app se quedaba
      // para siempre en la pantalla de carga.
      state = state.copyWith(initializing: false, authenticated: false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(submitting: true, clearError: true);
    final result =
        await _ref.read(loginUseCaseProvider)(email: email, password: password);
    final data = result.when(
      success: (d) => d,
      failure: (f) {
        state = state.copyWith(submitting: false, errorMessage: f.message);
        return null;
      },
    );
    if (data == null) return false;
    if (data.requiresEmailOtp) {
      _applyBranding(data.organization);
      state = state.copyWith(
        submitting: false,
        tempToken: data.tempToken,
        requiresEmailOtp: true,
        pendingEmail: data.email,
        mustChangePassword: data.mustChangePassword,
        authenticated: false,
      );
      return false;
    }
    if (data.requiresTotp || data.requiresOnboarding) {
      state = state.copyWith(
        submitting: false,
        tempToken: data.tempToken,
        authenticated: false,
      );
      return false;
    }
    // El router elige la pantalla de inicio por el rol (JURY -> Mis ferias).
    // La capa de datos ya guardó el usuario: se carga ANTES de marcar la
    // sesión; si no, el rol llegaba vacío y un jurado caía en la pantalla de
    // votación.
    final user = await _ref.read(authRepositoryProvider).currentUser();
    state = state.copyWith(
      submitting: false,
      authenticated: true,
      user: user,
      clearTempToken: true,
      mustChangePassword: data.mustChangePassword,
    );
    _hydrateProfile();
    return true;
  }

  Future<bool> verifyTotp(String code) async {
    final temp = state.tempToken;
    if (temp == null) {
      state = state.copyWith(errorMessage: 'Token temporal no disponible');
      return false;
    }
    state = state.copyWith(submitting: true, clearError: true);
    final result =
        await _ref.read(verifyLoginTotpUseCaseProvider)(tempToken: temp, code: code);
    final ok = result.when(
      success: (_) => true,
      failure: (f) {
        state = state.copyWith(submitting: false, errorMessage: f.message);
        return false;
      },
    );
    if (!ok) return false;
    // Igual que en login(): el rol tiene que estar antes de marcar la sesión.
    final user = await _ref.read(authRepositoryProvider).currentUser();
    state = state.copyWith(
      submitting: false,
      authenticated: true,
      user: user,
      clearTempToken: true,
    );
    _hydrateProfile();
    return true;
  }

  /// Paso 1 del acceso sin contraseña (estudiantes y jurados): solicita el
  /// código OTP al correo y guarda el tempToken EMAIL_PENDING para el paso 2.
  Future<bool> requestEmailLogin({required String email}) async {
    state = state.copyWith(submitting: true, clearError: true);
    final result =
        await _ref.read(requestEmailLoginUseCaseProvider)(email: email);
    final data = result.when(
      success: (d) => d,
      failure: (f) {
        state = state.copyWith(submitting: false, errorMessage: f.message);
        return null;
      },
    );
    if (data == null) return false;
    _applyBranding(data.organization);
    state = state.copyWith(
      submitting: false,
      tempToken: data.tempToken,
      requiresEmailOtp: true,
      pendingEmail: data.email,
      mustChangePassword: data.mustChangePassword,
      authenticated: false,
    );
    return true;
  }

  /// Paso 2 del acceso sin contraseña: verifica el código recibido por correo.
  Future<bool> verifyEmailLogin(String code) async {
    final temp = state.tempToken;
    if (temp == null || !state.requiresEmailOtp) {
      state = state.copyWith(
        errorMessage: 'Inicia de nuevo: el código expiró',
        requiresEmailOtp: false,
        clearTempToken: true,
      );
      return false;
    }
    state = state.copyWith(submitting: true, clearError: true);
    final result = await _ref
        .read(verifyEmailLoginUseCaseProvider)(tempToken: temp, code: code);
    final data = result.when(
      success: (d) => d,
      failure: (f) {
        state = state.copyWith(submitting: false, errorMessage: f.message);
        return null;
      },
    );
    if (data == null) return false;
    final user = await _ref.read(authRepositoryProvider).currentUser();
    state = state.copyWith(
      submitting: false,
      authenticated: true,
      user: user,
      requiresEmailOtp: false,
      pendingEmail: null,
      mustChangePassword: data.mustChangePassword,
      clearTempToken: true,
    );
    _hydrateProfile();
    return true;
  }

  /// Reenvía el código OTP del flujo de acceso sin contraseña en curso.
  Future<bool> resendEmailLogin() async {
    final temp = state.tempToken;
    if (temp == null || !state.requiresEmailOtp) return false;
    if (!await _ref.read(authRepositoryProvider).resendEmailLogin(
          tempToken: temp,
        )) {
      state = state.copyWith(errorMessage: 'No se pudo reenviar el código');
      return false;
    }
    return true;
  }

  void _applyBranding(OrganizationBranding? org) {
    if (org == null) return;
    _ref.read(brandingControllerProvider.notifier).apply(org);
  }

  Future<void> _hydrateProfile() async {
    final res = await _ref.read(getProfileUseCaseProvider)();
    res.when(
      success: (user) {
        state = state.copyWith(user: user);
      },
      failure: (_) {},
    );
  }

  /// Cambia la foto de perfil: sube la imagen, la enlaza al usuario y
  /// refresca el estado de sesión para que toda la app la vea al instante.
  Future<bool> changeAvatar(File file) async {
    state = state.copyWith(submitting: true, clearError: true);
    final res = await _ref.read(updateAvatarUseCaseProvider)(file);
    return res.when(
      success: (user) {
        state = state.copyWith(submitting: false, user: user);
        return true;
      },
      failure: (f) {
        state = state.copyWith(submitting: false, errorMessage: f.message);
        return false;
      },
    );
  }

  /// Guarda los campos editados del perfil propio.
  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    state = state.copyWith(submitting: true, clearError: true);
    final res = await _ref.read(updateProfileUseCaseProvider)(fields);
    return res.when(
      success: (user) {
        state = state.copyWith(submitting: false, user: user);
        return true;
      },
      failure: (f) {
        state = state.copyWith(submitting: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<void> logout() async {
    await _ref.read(logoutUseCaseProvider)();
    state = const AuthState(initializing: false, authenticated: false);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(submitting: true, clearError: true);
    final res = await _ref.read(changePasswordUseCaseProvider)(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    return res.when(
      success: (_) {
        state = state.copyWith(submitting: false, mustChangePassword: false);
        return true;
      },
      failure: (f) {
        state = state.copyWith(submitting: false, errorMessage: f.message);
        return false;
      },
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});