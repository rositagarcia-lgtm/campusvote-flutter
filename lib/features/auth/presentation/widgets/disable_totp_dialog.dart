import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';

/// Diálogo de confirmación para deshabilitar 2FA (incluye input de contraseña).
class TotpDisableCredentials {
  final String password;
  final String code;

  const TotpDisableCredentials({
    required this.password,
    required this.code,
  });
}

class DisableTotpDialog extends StatefulWidget {
  const DisableTotpDialog({super.key});

  static Future<TotpDisableCredentials?> show(BuildContext context) {
    return showDialog<TotpDisableCredentials>(
      context: context,
      builder: (_) => const DisableTotpDialog(),
    );
  }

  @override
  State<DisableTotpDialog> createState() => _DisableTotpDialogState();
}

class _DisableTotpDialogState extends State<DisableTotpDialog> {
  final _passwordCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _codeCtrl.dispose();
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
            'Confirma con tu contraseña y el código actual para deshabilitar '
            'la verificación en dos pasos.',
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
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(
              labelText: 'Código TOTP actual',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          const NoticeBanner(
            tone: AppTone.warning,
            message: 'Tu cuenta será menos segura.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        AppButton.danger(
          label: 'Deshabilitar',
          expand: false,
          onPressed: () => Navigator.of(context).pop(
            TotpDisableCredentials(
              password: _passwordCtrl.text,
              code: _codeCtrl.text,
            ),
          ),
        ),
      ],
    );
  }
}
