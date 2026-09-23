import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';

class ConfirmVoteDialog extends StatelessWidget {
  const ConfirmVoteDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const ConfirmVoteDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded,
          color: Colors.amber, size: 32),
      title: const Text('Confirmar voto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Una vez enviado, no podrás modificar tu selección.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Verifica tus opciones en el resumen antes de confirmar.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Cancelar',
          expand: false,
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: 'Confirmar voto',
          icon: Icons.check_rounded,
          expand: false,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}