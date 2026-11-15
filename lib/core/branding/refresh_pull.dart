import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/state/auth_controller.dart';

/// El jalón de cualquier pantalla vuelve a pedir los colores, aunque
/// la consulta de cada cinco segundos haya fallado.
Future<T> refreshPull<T>(WidgetRef ref, Future<T> Function() reload) async {
  final colors = ref.read(authControllerProvider.notifier).refreshBranding();
  final result = await reload();
  await colors;
  return result;
}
