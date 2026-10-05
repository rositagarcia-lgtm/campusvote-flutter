import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'app_palette.dart';
import '../../features/settings/presentation/settings_copy.dart';

/// Decodifica un data URL `data:image/png;base64,...` a bytes de imagen.
Uint8List? decodeQrDataUrl(String raw) {
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

/// Imagen de QR sobre una placa blanca de borde fino.
///
/// La placa blanca no es decoración: los lectores de QR necesitan contraste
/// alto sobre fondo claro, así que se mantiene también en modo oscuro. Si el
/// data URL no es válido o la imagen falla, se muestra el texto de ayuda en vez
/// de un hueco vacío.
class AppQrImage extends StatelessWidget {
  const AppQrImage({
    super.key,
    required this.dataUrl,
    this.size = 240,
    this.fallbackLabel = 'QR no disponible',
    this.semanticsLabel = 'Código QR',
  });

  /// QR en formato data URL (`data:image/png;base64,...`) generado por backend.
  final String dataUrl;

  /// Lado de la placa; 240 px es el tamaño que espera el lector.
  final double size;

  final String fallbackLabel;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bytes = decodeQrDataUrl(dataUrl);

    Widget content;
    if (bytes != null) {
      content = Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallback(context),
      );
    } else {
      content = _fallback(context);
    }

    return Semantics(
      label: SettingsCopy.of(context).t(semanticsLabel),
      image: true,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.rMedium,
          border: Border.all(color: appBorder(isDark)),
        ),
        child: content,
      ),
    );
  }

  /// Estado sin QR legible: texto explicativo, nunca un rectángulo vacío.
  Widget _fallback(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Text(
        SettingsCopy.of(context).t(fallbackLabel),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
      ),
    );
  }
}
