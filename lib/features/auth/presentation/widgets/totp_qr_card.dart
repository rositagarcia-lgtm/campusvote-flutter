import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_qr_image.dart';

/// Tarjeta que muestra el código QR generado por el backend a partir del
/// secreto TOTP, con la URI de enrolment debajo para copiar a mano.
class TotpQrCard extends StatelessWidget {
  final String qrCodeDataUrl;
  final String uri;
  const TotpQrCard({
    super.key,
    required this.qrCodeDataUrl,
    required this.uri,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          AppQrImage(
            dataUrl: qrCodeDataUrl,
            semanticsLabel: 'Código QR de configuración de la aplicación 2FA',
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            uri,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
