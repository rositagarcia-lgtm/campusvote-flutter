// voting_ranking_header.dart

import 'package:flutter/material.dart';

import 'package:campusvote_flutter/core/theme/app_icons.dart';
import 'package:campusvote_flutter/core/theme/app_dimensions.dart';
import 'package:campusvote_flutter/features/settings/presentation/settings_copy.dart';

/// Encabezado del ranking de votación: muestra cuántas rúbricas se han finalizado
/// y cómo se ordenan los proyectos según el criterio propio del jurado.
class VotingRankingHeader extends StatelessWidget {
  const VotingRankingHeader({
    super.key,
    required this.scored,
    required this.total,
  });

  final int scored;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = SettingsCopy.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(PhosphorIconsRegular.trendUp, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy.t('Tu ranking por rúbrica'),
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                scored == 0
                    ? copy.t(
                        'Aún no finalizas rúbricas en esta feria. Puedes votar igual.')
                    : (copy.isEnglish
                        ? 'Sorted from highest to lowest using the $scored of $total rubrics you finished. Only you can see it.'
                        : 'Ordenado de mayor a menor según las $scored de $total rúbricas que finalizaste. Solo tú lo ves.'),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}