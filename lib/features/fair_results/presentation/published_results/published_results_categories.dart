part of '../published_results_page.dart';

class _MyProjectBanner extends StatelessWidget {
  const _MyProjectBanner({required this.result});

  final MyProjectResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = SettingsCopy.of(context);
    final position = result.position;
    final projectName = result.projectName;
    final categoryName = result.categoryName == 'Sin categoría'
        ? copy.t(result.categoryName)
        : result.categoryName;
    final (icon, color, text) = switch (position) {
      1 => (
          PhosphorIconsFill.trophy,
          _gold,
          copy.isEnglish
              ? 'Your project “$projectName” won the $categoryName category!'
              : '¡Tu proyecto «$projectName» ganó la categoría $categoryName!'
        ),
      int p when p <= 3 => (
          PhosphorIconsFill.medal,
          medalColor(p),
          copy.isEnglish
              ? 'Your project “$projectName” placed $p in $categoryName.'
              : 'Tu proyecto «$projectName» quedó en el $p.° puesto de $categoryName.'
        ),
      int p => (
          PhosphorIconsRegular.medal,
          theme.colorScheme.primary,
          copy.isEnglish
              ? 'Your project “$projectName” placed $p in $categoryName.'
              : 'Tu proyecto «$projectName» quedó en el $p.° puesto de $categoryName.'
        ),
      null => (
          PhosphorIconsRegular.handHeart,
          theme.colorScheme.primary,
          copy.isEnglish
              ? '“$projectName” received no jury votes this time. Thank you for taking part!'
              : '«$projectName» no recibió votos del jurado esta vez. ¡Gracias por participar!'
        ),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(text,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final CategoryPodium category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final winner = category.winner;
    // El podio muestra el primero de cada puesto 1.°–3.°; el resto (4.° en
    // adelante o un empate en el mismo puesto) sigue en la lista.
    final onPodium = {
      for (final position in [1, 2, 3])
        category.podium.where((p) => p.position == position).firstOrNull,
    }..remove(null);
    final rest = category.podium.where((p) => !onPodium.contains(p)).toList();
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.rLarge,
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.m, AppSpacing.m, AppSpacing.m, AppSpacing.s),
            child: Text(
                (category.name == 'Sin categoría'
                        ? SettingsCopy.of(context).t(category.name)
                        : category.name)
                    .toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.2, fontWeight: FontWeight.w800)),
          ),
          if (winner == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m, 0, AppSpacing.m, AppSpacing.m),
              child: Text(
                  SettingsCopy.of(context)
                      .t('Esta categoría no recibió votos del jurado.'),
                  style: theme.textTheme.bodyMedium),
            )
          else
            _AnimatedPodium(category: category),
          for (final entry in rest) _PlaceTile(entry: entry),
          const SizedBox(height: AppSpacing.s),
        ],
      ),
    );
  }
}
