import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../state/auth_controller.dart';

/// Cierre de sesión con confirmación, compartido por todos los paneles.
///
/// Un toque accidental en "salir" obligaba a pedir otro código o volver a
/// escribir la contraseña; por eso ningún punto de la app cierra sesión sin
/// preguntar primero.
Future<void> confirmAndLogout(BuildContext context, WidgetRef ref) async {
  final confirm = await AppDialog.confirm(
    context,
    title: 'Cerrar sesión',
    message: '¿Seguro que quieres salir de la aplicación?',
    confirmLabel: 'Salir',
    destructive: true,
  );
  if (confirm != true || !context.mounted) return;
  await ref.read(authControllerProvider.notifier).logout();
  if (context.mounted) context.go('/splash');
}
