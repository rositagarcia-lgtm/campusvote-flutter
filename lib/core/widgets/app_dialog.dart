import 'package:flutter/material.dart';

import 'app_button.dart';
import '../../features/settings/presentation/settings_copy.dart';

/// Diálogos de confirmación e información con la misma jerarquía que el resto
/// de la app: título claro, mensaje en tono secundario y acciones compactas.
class AppDialog {
  const AppDialog._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text(SettingsCopy.of(ctx).t(title)),
        content: Text(SettingsCopy.of(ctx).t(message),
            style: Theme.of(ctx).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(SettingsCopy.of(ctx).t(cancelLabel)),
          ),
          destructive
              ? AppButton.danger(
                  label: SettingsCopy.of(ctx).t(confirmLabel),
                  expand: false,
                  dense: true,
                  onPressed: () => Navigator.of(ctx).pop(true),
                )
              : AppButton(
                  label: SettingsCopy.of(ctx).t(confirmLabel),
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
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(SettingsCopy.of(ctx).t(title)),
        content: Text(SettingsCopy.of(ctx).t(message),
            style: Theme.of(ctx).textTheme.bodyMedium),
        actions: [
          AppButton(
            label: SettingsCopy.of(ctx).t(buttonLabel),
            expand: false,
            dense: true,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
