// fair_project_filter_bar.dart

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_segmented_option.dart';
import '../../../data/models/jury_models.dart';
import '../fair_project_filter.dart';

/// Filtros de proyectos como control segmentado.
///
/// Reutiliza el mismo control que el tamaño de texto y el idioma de
/// Configuración: una sola implementación, con la misma zona táctil y la misma
/// semántica. Los contadores se calculan con las mismas funciones que filtran
/// la lista, así que el número y el contenido nunca se contradicen.
class FairProjectFilterBar extends StatelessWidget {
  const FairProjectFilterBar({
    super.key,
    required this.selected,
    required this.projects,
    required this.submittedIds,
    required this.onSelected,
  });

  final FairProjectFilter selected;
  final List<FairProjectModel> projects;
  final Set<String> submittedIds;
  final ValueChanged<FairProjectFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final filter in FairProjectFilter.values) ...[
          if (filter != FairProjectFilter.values.first)
            const SizedBox(width: AppSpacing.s),
          Expanded(
            child: AppSegmentOption(
              label: filter.label,
              selected: selected == filter,
              onTap: () => onSelected(filter),
              style: AppSegmentStyle.filled,
              count: filterFairProjects(
                projects: projects,
                filter: filter,
                submittedIds: submittedIds,
              ).length,
            ),
          ),
        ],
      ],
    );
  }
}