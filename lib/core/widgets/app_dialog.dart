import 'package:flutter/material.dart';

import 'app_button.dart';

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
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelLabel),
            ),
            destructive
                ? AppButton.danger(
                    label: confirmLabel,
                    expand: false,
                    onPressed: () => Navigator.of(ctx).pop(true),
                  )
                : AppButton(
                    label: confirmLabel,
                    expand: false,
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
          ],
        );
      },
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
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton(
            label: buttonLabel,
            expand: false,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}