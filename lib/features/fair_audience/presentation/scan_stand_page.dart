import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/routing/deep_links.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_appbar.dart';

/// `/scan` — escanea el QR impreso en el stand y abre ese proyecto: el
/// alumno para opinar, el jurado para su rúbrica (lo decide la ruta del QR).
class ScanStandPage extends StatefulWidget {
  const ScanStandPage({super.key});

  @override
  State<ScanStandPage> createState() => _ScanStandPageState();
}

class _ScanStandPageState extends State<ScanStandPage> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handled = false;
  String? _hint;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final code in capture.barcodes) {
      final raw = code.rawValue;
      if (raw == null) continue;
      final stand = parseStandQr(raw);
      if (stand == null) {
        setState(
            () => _hint = 'Ese código no es el QR de un stand de CampusVote.');
        continue;
      }
      _handled = true;
      context.go('/ferias/${stand.$1}/proyectos/${stand.$2}');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Escanear QR del stand'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Text(
                  error.errorCode == MobileScannerErrorCode.permissionDenied
                      ? 'Permite el uso de la cámara para escanear el QR del stand.'
                      : 'No pudimos abrir la cámara.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Marco guía.
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: AppRadii.rLarge,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.l,
            right: AppSpacing.l,
            bottom: AppSpacing.xl,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: AppRadii.rLarge,
              ),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.qrCode, color: Colors.white),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      _hint ??
                          'Apunta al código QR impreso en el stand del proyecto.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
