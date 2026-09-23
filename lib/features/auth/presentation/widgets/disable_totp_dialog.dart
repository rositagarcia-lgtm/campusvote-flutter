import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';

/// Diálogo de confirmación para deshabilitar 2FA (incluye input de contraseña).
class DisableTotpDialog extends StatefulWidget {
  const DisableTotpDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const DisableTotpDialog(),
    );
  }

  @override
  State<DisableTotpDialog> createState() => _DisableTotpDialogState();
}

class _DisableTotpDialogState extends State<DisableTotpDialog> {
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Deshabilitar 2FA'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirma con tu contraseña para deshabilitar la verificación '
            'en dos pasos.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.warning, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tu cuenta será menos segura.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.warning),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        AppButton.danger(
          label: 'Deshabilitar',
          expand: false,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}