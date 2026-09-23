import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_user.dart';
import 'auth_events.dart';
import 'auth_providers.dart';

class AuthState {
  final bool initializing;
  final bool authenticated;
  final AuthUser? user;
  final bool submitting;
  final String? tempToken; // para 2FA
  final String? errorMessage;
  final bool mustChangePassword;

  const AuthState({
    this.initializing = true,
    this.authenticated = false,
    this.user,
    this.submitting = false,
    this.tempToken,
    this.errorMessage,
    this.mustChangePassword = false,
  });

  AuthState copyWith({
    bool? initializing,
    bool? authenticated,
    AuthUser? user,
    bool? submitting,
    String? tempToken,
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