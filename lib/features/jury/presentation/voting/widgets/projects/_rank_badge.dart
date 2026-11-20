// _rank_badge.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart'
    show AppRadii, AppSpacing;

/// Badge de posición (rank) para proyectos en la lista de votación.
class RankBadge extends StatelessWidget {
  const RankBadge({super.key, required this.rank});

  final int? rank;

  // Oro, plata y bronce para el podio; el resto en tono neutro.
  static const _podium = [
    Color(0xFFC9A227),
    Color(0xFF8E9AA6),
    Color(0xFFB0703C)
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final podium = rank != null && rank! <= 3;
    final color = podium ? _podium[rank! - 1] : scheme.onSurfaceVariant;
    return SizedBox(
      width: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (podium) Icon(PhosphorIconsFill.medal, size: 18, color: color),
          Text(
            rank == null ? '—' : '$rank°',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}