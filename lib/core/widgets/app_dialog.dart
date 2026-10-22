import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_button.dart';
import '../../features/settings/presentation/settings_copy.dart';

/// Diálogos de confirmación e información con la misma jerarquía que el resto
/// de la app: título claro, mensaje en tono secundario y acciones compactas.
/// En iOS se muestran como alerta nativa (CupertinoAlertDialog): acciones a
/// lo ancho, la destructiva en rojo y la principal en negrita.
class AppDialog {
  const AppDialog._();

  static bool _isApple(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) async {
    final copy = SettingsCopy.of(context);
    if (_isApple(context)) {
      final result = await showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(copy.t(title)),
          content: Text(copy.t(message)),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(copy.t(cancelLabel)),
            ),
            CupertinoDialogAction(
              isDefaultAction: !destructive,
              isDestructiveAction: destructive,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(copy.t(confirmLabel)),
            ),
          ],
        ),
      );
      return result ?? false;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text(copy.t(title)),
        content: Text(copy.t(message),
            style: Theme.of(ctx).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(copy.t(cancelLabel)),
          ),
          destructive
              ? AppButton.danger(
                  label: copy.t(confirmLabel),
                  expand: false,
                  dense: true,
                  onPressed: () => Navigator.of(ctx).pop(true),
                )
              : AppButton(
                  label: copy.t(confirmLabel),
                  expand: false,
                  dense: true,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = 'Entendido',
  }) {
    final copy = SettingsCopy.of(context);
    if (_isApple(context)) {
      return showCupertinoDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(copy.t(title)),
          content: Text(copy.t(message)),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(copy.t(buttonLabel)),
            ),
          ],
        ),
      );
    }

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(copy.t(title)),
        content: Text(copy.t(message),
            style: Theme.of(ctx).textTheme.bodyMedium),
        actions: [
          AppButton(
            label: copy.t(buttonLabel),
            expand: false,
            dense: true,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
