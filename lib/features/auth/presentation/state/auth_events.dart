/// Eventos globales del flujo de autenticación que el resto de la app debe
/// observar (logout forzado por 401, sesión expirada, etc.).
///
/// Implementado como un contador simple: cada vez que se incrementa, los
/// listeners (auth controller, router) reaccionan y limpian su estado.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthEvents {
  final int logoutCount;
  const AuthEvents({this.logoutCount = 0});

  AuthEvents copyWith({int? logoutCount}) =>
      AuthEvents(logoutCount: logoutCount ?? this.logoutCount);
}

class AuthEventsController extends StateNotifier<AuthEvents> {
  AuthEventsController() : super(const AuthEvents());

  void notifyForcedLogout() {
    state = state.copyWith(logoutCount: state.logoutCount + 1);
  }
}

final authEventsProvider =
    StateNotifierProvider<AuthEventsController, AuthEvents>(
  (ref) => AuthEventsController(),
);
