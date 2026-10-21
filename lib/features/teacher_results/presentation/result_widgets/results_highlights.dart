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
    final strength = _Highlight(
      label: 'Tu fortaleza',
      criterion: strongest,
      icon: PhosphorIconsRegular.trendUp,
      color: AppColors.success,
    );
    final opportunity = _Highlight(
      label: 'Para mejorar',
      criterion: weakest,
      icon: PhosphorIconsRegular.target,
      color: AppColors.warning,
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 360
          ? Column(children: [
              strength,
              const SizedBox(height: AppSpacing.s),
              opportunity,
            ])
          : Row(children: [
              Expanded(child: strength),
              const SizedBox(width: AppSpacing.s),
              Expanded(child: opportunity),
            ]),
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
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.08), scheme.surface),
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ]),
          const SizedBox(height: AppSpacing.m),
          Text(
            criterion.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.s),
          Text('${_score(criterion.average)} / 5',
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              )),
        ],
      ),
    );
  }
}

/// Fila con barra de 0 a 5 que se llena al aparecer.
