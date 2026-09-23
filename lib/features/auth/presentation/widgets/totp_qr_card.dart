import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';

/// Decodifica un data URL `data:image/png;base64,...` a bytes de imagen.
Uint8List? decodeDataUrl(String raw) {
  if (raw.isEmpty) return null;
  const marker = 'base64,';
  final idx = raw.indexOf(marker);
  if (idx < 0) return null;
  try {
    return base64Decode(raw.substring(idx + marker.length));
  } catch (_) {
    return null;
  }
}

/// Tarjeta que muestra el código QR generado por el backend a partir del
/// secreto TOTP.
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
    final imageBytes = decodeDataUrl(qrCodeDataUrl);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: AppRadii.rMedium,
            child: imageBytes != null
                ? Image.memory(
                    imageBytes,
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                  )
                : Container(
                    width: 240,
                    height: 240,
                    color: theme.dividerColor,
                    alignment: Alignment.center,
                    child: Text(
                      'QR no disponible',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
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