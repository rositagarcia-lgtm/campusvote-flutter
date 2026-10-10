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

part 'auth_state.dart';
part 'auth_controller_email.dart';
part 'auth_controller_profile.dart';

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

  /// Estado actual para las extensiones de la misma biblioteca.
  AuthState get currentState => state;

  /// Actualiza el estado desde las extensiones de la misma biblioteca.
  void patch(AuthState value) => state = value;

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
        // La sesión persistida solo guarda el `organizationId`: primero se
        // pinta la marca recordada y luego se refresca desde el servidor.
        _ref
            .read(brandingControllerProvider.notifier)
            .restoreCached(user.organizationId);
        unawaited(_loadBranding(user.organizationId));
        // La copia local puede estar desactualizada (foto, nombre): se
        // refresca desde `/me` sin bloquear la apertura.
        unawaited(_hydrateProfile());
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

  Future<void> logout() async {
    await _ref.read(logoutUseCaseProvider)();
    _resetBranding();
    state = const AuthState(initializing: false, authenticated: false);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
