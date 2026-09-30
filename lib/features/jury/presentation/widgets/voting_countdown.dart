import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_status_chip.dart';

/// Cuenta regresiva hasta el cierre de la votación.
///
/// Recibe `endsAt` de la asignación; si la feria no trae fecha, o ya pasó,
/// se oculta en vez de mostrar un contador en negativo.
class VotingCountdown extends StatefulWidget {
  const VotingCountdown({super.key, required this.endsAt, this.startsAt});

  final DateTime? endsAt;
  final DateTime? startsAt;

  @override
  State<VotingCountdown> createState() => _VotingCountdownState();
}

class _VotingCountdownState extends State<VotingCountdown> {
  Timer? _timer;
  late Duration _remaining = _compute();

  Duration _compute() {
    final endsAt = widget.endsAt;
    if (endsAt == null) return Duration.zero;
    final diff = endsAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _remaining = _compute());
    });
  }

  @override
  void didUpdateWidget(covariant VotingCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endsAt != widget.endsAt) {
      _remaining = _compute();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final endsAt = widget.endsAt;
    if (endsAt == null) return const SizedBox.shrink();

    final closed = _remaining == Duration.zero;
    final startsAt = widget.startsAt;
    final startsIn = startsAt?.difference(DateTime.now());
    final pending = startsIn != null && !startsIn.isNegative;

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;
    // Cerrado = aviso; abierta = acento de marca. Los tonos traen su propia
    // variante oscura, así que el contador no se apaga en modo oscuro.
    final tone = closed ? AppTone.neutral : AppTone.primary;
    final colors = appToneColors(
      tone,
      isDark: Theme.of(context).brightness == Brightness.dark,
      primary: context.brandPrimary,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: AppRadii.rMedium,
      ),
      child: Row(
        children: [
          Icon(
            closed ? Icons.timer_off_rounded : Icons.timer_rounded,
            size: AppDimensions.iconMedium,
            color: colors.fg,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              pending
                  ? 'La votación abre en ${_format(startsIn)}'
                  : closed
                      ? 'La votación de esta feria ya cerró'
                      : 'Cierra en ${days > 0 ? '${days}d ' : ''}'
                          '${_pad(hours)}:${_pad(minutes)}:${_pad(seconds)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.fg,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');

  static String _format(Duration d) {
    if (d.inDays > 0) return '${d.inDays} días';
    if (d.inHours > 0) return '${d.inHours} h ${d.inMinutes % 60} min';
    return '${d.inMinutes} min';
  }
}
