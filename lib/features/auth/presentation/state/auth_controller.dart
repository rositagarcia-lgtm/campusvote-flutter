import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/branding/organization_branding.dart';
import '../../../../core/branding/organization_branding_repository.dart';
import '../../domain/entities/auth_role.dart';
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
  final String? pendingQrCode; // QR opcional como segunda vía del OTP
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
    this.pendingQrCode,
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
    String? pendingQrCode,
    String? errorMessage,
    bool? mustChangePassword,
    bool clearTempToken = false,
    bool clearError = false,
    bool clearPendingQrCode = false,
  }) {
    return AuthState(
      initializing: initializing ?? this.initializing,
      authenticated: authenticated ?? this.authenticated,
      user: user ?? this.user,
      submitting: submitting ?? this.submitting,
      tempToken: clearTempToken ? null : (tempToken ?? this.tempToken),
      requiresEmailOtp: requiresEmailOtp ?? this.requiresEmailOtp,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      pendingQrCode:
          clearPendingQrCode ? null : (pendingQrCode ?? this.pendingQrCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}

/// Qué hacer tras un intento de acceso con contraseña en el panel de jurado.
///
/// El backend es la autoridad del rol: si la contraseña es válida pero la
/// cuenta no es de jurado, se cierra la sesión en vez de dejar al usuario
/// dentro de un panel ajeno.
enum JuryLoginOutcome {
  /// Sesión iniciada y la cuenta es de jurado.
  granted,

  /// Credenciales válidas pero la cuenta no es de jurado: hay que cerrar la
  /// sesión y avisar.
  notJury,

  /// La cuenta exige además un código enviado al correo.
  needsEmailCode,

  /// La cuenta exige el código de la app autenticadora.
  needsTotp,

  /// Credenciales incorrectas u otro error (ver `AuthState.errorMessage`).
  failed,
}

JuryLoginOutcome resolveJuryLoginOutcome({
  required bool ok,
  required AuthState state,
}) {
  if (ok) {
    return state.user?.role == AuthRole.jury
        ? JuryLoginOutcome.granted
        : JuryLoginOutcome.notJury;
  }
  if (state.tempToken == null) return JuryLoginOutcome.failed;
  return state.requiresEmailOtp
      ? JuryLoginOutcome.needsEmailCode
      : JuryLoginOutcome.needsTotp;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState()) {
    _bootstrap();
    // Escucha logout forzado (401 → refresh fallido).
    _ref.listen<AuthEvents?>(authEventsProvider, (prev, next) {
      if (next != null && prev != null && next.logoutCount > prev.logoutCount) {
        _resetBranding();
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
        // La sesión persistida solo guarda el `organizationId`; sin esto el
        // panel abriría con la marca CampusVote en vez de la organización.
        unawaited(_loadBranding(user.organizationId));
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
        pendingQrCode: data.qrCode,
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
    final result = await _ref.read(verifyLoginTotpUseCaseProvider)(
        tempToken: temp, code: code);
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

  /// Acceso del ESTUDIANTE (paso 1): solicita el código OTP al correo y guarda
  /// el tempToken EMAIL_PENDING para el paso 2.
  ///
  /// El flujo con contraseña (jurado) usa [login] en su lugar.
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
      pendingQrCode: data.qrCode,
      mustChangePassword: data.mustChangePassword,
      authenticated: false,
    );
    return true;
  }

  /// Paso 2 del acceso del estudiante: verifica el código recibido por correo.
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
    final result = await _ref.read(verifyEmailLoginUseCaseProvider)(
        tempToken: temp, code: code);
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
      clearPendingQrCode: true,
      mustChangePassword: data.mustChangePassword,
      clearTempToken: true,
    );
    _hydrateProfile();
    return true;
  }

  /// Reenvía el código OTP del flujo del estudiante en curso.
  Future<bool> resendEmailLogin() async {
    final temp = state.tempToken;
    if (temp == null || !state.requiresEmailOtp) return false;
    state = state.copyWith(clearError: true);
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

  /// Consulta la organización del usuario autenticado y pinta su identidad.
  ///
  /// Silencioso a propósito: si falla (sin red, organización borrada) el panel
  /// se queda con la marca CampusVote en vez de bloquear la sesión.
  Future<void> _loadBranding(String? organizationId) async {
    if (organizationId == null || organizationId.isEmpty) return;
    final res = await _ref
        .read(organizationBrandingRepositoryProvider)
        .fetch(organizationId);
    if (res.isSuccess) _applyBranding(res.dataOrNull);
  }

  /// Vuelve a la identidad de CampusVote.
  ///
  /// Sin esto los colores y el nombre de la organización de la sesión anterior
  /// se quedaban pintados en el tema global: el siguiente usuario entraba
  /// viendo la marca de otro tenant, y el splash se quedaba con el nombre
  /// viejo. Se llama también en el logout forzado por 401.
  void _resetBranding() {
    _ref.read(brandingControllerProvider.notifier).reset();
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
    _resetBranding();
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
