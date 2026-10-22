part of '../published_results_page.dart';

const _gold = Color(0xFFD4A017);
const _silver = Color(0xFF9AA4AE);
const _bronze = Color(0xFFB0703C);

Color medalColor(int position) => switch (position) {
      1 => _gold,
      2 => _silver,
      _ => _bronze,
    };

/// `/resultados/:fairId` — podio de cada categoría tal como se publicó.
/// Sin cantidad de votos: el voto del jurado es secreto.
class PublishedResultsPage extends ConsumerWidget {
  const PublishedResultsPage({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(publishedResultsProvider(fairId));
    Future<void> reload() =>
        ref.refresh(publishedResultsProvider(fairId).future);
    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Resultados'),
      body: RefreshIndicator.adaptive(
        onRefresh: reload,
        child: results.when(
          loading: () => const AppLoader(),
          error: (error, _) => AppErrorView(
            message: mapExceptionToFailure(error).message,
            onRetry: reload,
          ),
          data: (data) => _ResultsBody(results: data),
        ),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({required this.results});

  final PublishedResults results;

  @override
  Widget build(BuildContext context) {
    if (results.categories.isEmpty && results.audienceFavorite == null) {
      return _PendingResults(results: results);
    }
    final theme = Theme.of(context);
    final date = results.fair.publishedAt?.toLocal();
    var i = 0;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Text(results.fair.name,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        if (date != null)
          Text('Resultados oficiales · ${date.day}/${date.month}/${date.year}',
              style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.l),
        for (final mine in results.myProjects) ...[
          AppMotion.reveal(i++, _MyProjectBanner(result: mine)),
          const SizedBox(height: AppSpacing.s),
        ],
        if (AppFeatures.studentCertificates && results.myProjects.isNotEmpty) ...[
          OutlinedButton.icon(
            onPressed: () => context.push('/certificados'),
            icon: const Icon(PhosphorIconsRegular.certificate),
            label: const Text('Ver mis certificados'),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        for (final category in results.categories) ...[
          AppMotion.reveal(i++, _CategoryCard(category: category)),
          const SizedBox(height: AppSpacing.m),
        ],
        if (results.audienceFavorite != null)
          AppMotion.reveal(i++, _FavoriteCard(name: results.audienceFavorite!)),
        const SizedBox(height: AppSpacing.l),
        Text(
          'Gana el proyecto más votado por el jurado de cada categoría; un '
          'empate lo decide el puntaje de la rúbrica. Los votos son secretos.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
