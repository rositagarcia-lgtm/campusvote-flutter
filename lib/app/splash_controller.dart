import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/state/auth_controller.dart';

class SplashState {
  final bool ready;
  const SplashState({this.ready = false});
}

class SplashController extends StateNotifier<SplashState> {
  SplashController(this._ref) : super(const SplashState());

  final Ref _ref;

  Future<void> initialize() async {
    // Espera bootstrap de auth.
    final auth = _ref.read(authControllerProvider);
    if (auth.initializing) {
      // No-op: el splash se ocultará cuando authControllerProvider
      // cambie a initializing = false vía el router redirect.
    }
    // Marca listo como cortesía (no bloquea el router).
    state = const SplashState(ready: true);
  }
}

final splashControllerProvider =
    StateNotifierProvider<SplashController, SplashState>(
  (ref) => SplashController(ref),
);