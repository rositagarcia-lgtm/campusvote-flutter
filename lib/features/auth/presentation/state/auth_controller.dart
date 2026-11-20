import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/branding/organization_branding.dart';
import '../../../../core/branding/organization_branding_repository.dart';
import '../../../../core/push/push_sync.dart';
import '../../../../core/session/clear_account_state.dart';
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
        unawaited(_ref
            .read(localStorageProvider)
            .remove(AppConstants.prefsIntroSeen));
        _resetBranding();
        _resetBrandingFetch();
        state = const AuthState(initializing: false, authenticated: false);
        clearAccountState(_ref);
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
          // La sesión persistida debe recuperar también la obligación de
          // cambiar la contraseña temporal; el backend no la vuelve a exigir.
          mustChangePassword: user.mustChangePassword,
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
    _resetBrandingFetch();
    final user = await _ref.read(authRepositoryProvider).currentUser();
    state = state.copyWith(
      submitting: false,
      authenticated: true,
      user: user,
      clearTempToken: true,
      mustChangePassword:
          data.mustChangePassword && AuthRole.usesPassword(user?.role),
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
    final verified = result.when(
      success: (d) => d,
      failure: (f) {
        state = state.copyWith(submitting: false, errorMessage: f.message);
        return null;
      },
    );
    if (verified == null) return false;
    // Igual que en login(): el rol tiene que estar antes de marcar la sesión.
    _resetBrandingFetch();
    final user = await _ref.read(authRepositoryProvider).currentUser();
    state = state.copyWith(
      submitting: false,
      authenticated: true,
      user: user,
      clearTempToken: true,
      mustChangePassword:
          verified.mustChangePassword && AuthRole.usesPassword(user?.role),
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
  /// Silencioso a propósito: si falla (sin red, organización borrada, 401/403)
  /// el panel se queda con la marca CampusVote en vez de bloquear la sesión.
  /// El error de autorización solo pausa el polling; el cierre de sesión lo
  /// decide el interceptor, que es quien realmente intentó refrescar el token.
  Future<void> _loadBranding(String? organizationId) async {
    if (organizationId == null || organizationId.isEmpty) return;
    final pending = _brandingInFlight;
    if (pending != null) {
      await pending;
      return;
    }

    final future =
        _ref.read(organizationBrandingRepositoryProvider).fetch(organizationId);
    _brandingInFlight = future;
    try {
      final res = await future;
      final failure = res.failureOrNull;
      if (failure == null) {
        _brandingFailureCount = 0;
        _brandingPollSkipTicks = 0;
        _brandingPollPaused = false;
        if (state.authenticated &&
            state.user?.organizationId == organizationId) {
          _applyBranding(res.dataOrNull);
        }
        return;
      }

      _brandingFailureCount++;
      if (failure is UnauthorizedFailure || failure is ForbiddenFailure) {
        // 401/403: no cerramos la sesión, pero dejar de insistir evita llenar
        // el log con peticiones inútiles. Solo un reintento manual lo reactiva.
        _brandingPollPaused = true;
        return;
      }
      // Fallo transitorio: backoff exponencial en ticks del poll (5 s each).
      _brandingPollSkipTicks =
          (1 << (_brandingFailureCount - 1).clamp(0, 3)).clamp(1, 8).toInt();
    } finally {
      _brandingInFlight = null;
    }
  }

  Future<Result<OrganizationBranding>>? _brandingInFlight;

  /// El poll automático se detiene tras 401/403. No depende del reintento
  /// manual: el interceptor sigue siendo quien decide si hay logout forzado.
  bool _brandingPollPaused = false;

  /// Fallos transitorios consecutivos; determinan cuántos ticks se omiten.
  int _brandingFailureCount = 0;
  int _brandingPollSkipTicks = 0;

  void _resetBrandingFetch() {
    _brandingPollPaused = false;
    _brandingFailureCount = 0;
    _brandingPollSkipTicks = 0;
    _brandingInFlight = null;
  }

  /// Entrada del polling de 5 s. Respeta la pausa y el backoff; no sirve para
  /// reintentos manuales (para eso está [retryBranding]).
  Future<void> refreshBranding() async {
    if (_brandingPollPaused) return;
    if (_brandingPollSkipTicks > 0) {
      _brandingPollSkipTicks--;
      return;
    }
    await _loadBranding(state.user?.organizationId);
  }

  /// Reintento explícito (pull-to-refresh, entrada a una pantalla, ajustes).
  /// Limpia el estado de error del polling y vuelve a consultar aunque estuviera
  /// pausado por un 401/403.
  Future<void> retryBranding() async {
    _resetBrandingFetch();
    await _loadBranding(state.user?.organizationId);
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

  /// Recarga `/me` después de una acción que cambia el rol del usuario, como
  /// aceptar una invitación de jurado. El router observa el estado, así que el
  /// cambio de rol se propaga sin recrear el controller.
  Future<void> refreshProfile() => _hydrateProfile();

  Future<void> _hydrateProfile() async {
    final expectedUserId = state.user?.id;
    if (!state.authenticated || expectedUserId == null) return;
    final res = await _ref.read(getProfileUseCaseProvider)();
    res.when(
      success: (user) {
        if (state.authenticated &&
            state.user?.id == expectedUserId &&
            user.id == expectedUserId) {
          state = state.copyWith(
            user: user,
            // `/me` es la fuente vigente: corrige flags obsoletos guardados
            // en el dispositivo tras cambiar la contraseña en otro lado.
            mustChangePassword: user.mustChangePassword,
          );
        }
      },
      failure: (_) {},
    );
  }

  Future<void> logout() async {
    await unregisterPushDevice(_ref, forced: true);
    await _ref.read(localStorageProvider).remove(AppConstants.prefsIntroSeen);
    await _ref.read(logoutUseCaseProvider)();
    _resetBranding();
    _resetBrandingFetch();
    state = const AuthState(initializing: false, authenticated: false);
    clearAccountState(_ref);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
