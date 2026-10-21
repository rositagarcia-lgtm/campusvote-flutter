part of '../teacher_results_widgets.dart';

class ResultsHighlights extends StatelessWidget {
  const ResultsHighlights({
    super.key,
    required this.strongest,
    required this.weakest,
  });

  final CriterionResult strongest;
  final CriterionResult weakest;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Highlight(
            label: 'Tu fortaleza',
            criterion: strongest,
            icon: PhosphorIconsRegular.trendUp,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: _Highlight(
            label: 'Para mejorar',
            criterion: weakest,
            icon: PhosphorIconsRegular.target,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight({
    required this.label,
    required this.criterion,
    required this.icon,
    required this.color,
  });

  final String label;
  final CriterionResult criterion;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: _cardDecoration(theme.colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.s),
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            criterion.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text('${_score(criterion.average)} de 5',
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Fila con barra de 0 a 5 que se llena al aparecer.
