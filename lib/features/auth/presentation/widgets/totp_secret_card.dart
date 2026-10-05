import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../../settings/presentation/settings_copy.dart';

/// Secreto TOTP para enrolar la aplicación a mano, con acción de copiar.
///
/// Es la alternativa al QR cuando el teléfono no puede escanearlo.
class TotpSecretCard extends StatelessWidget {
  final String secret;
  const TotpSecretCard({super.key, required this.secret});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            SettingsCopy.of(context).t('SECRETO (ENTRADA MANUAL)'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: appMuted(isDark),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          SelectableText(
            secret,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon:
                  const Icon(Icons.copy_rounded, size: AppDimensions.iconSmall),
              label: Text(SettingsCopy.of(context).t('Copiar')),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: secret));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(SettingsCopy.of(context).t('Secreto copiado'))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
