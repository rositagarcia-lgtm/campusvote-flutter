import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_card.dart';

/// Tarjeta con el secreto TOTP en formato monoespaciado, con botón copiar.
class TotpSecretCard extends StatelessWidget {
  final String secret;
  const TotpSecretCard({super.key, required this.secret});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Secreto (entrada manual)',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          SelectableText(
            secret,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'monospace',
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copiar'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: secret));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Secreto copiado')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}