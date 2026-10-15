import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_appbar.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../data/published_results_repository.dart';
import '../domain/published_results.dart';

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
    Future<void> reload() => ref.refresh(publishedResultsProvider(fairId).future);
    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Resultados'),
      body: RefreshIndicator(
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

class _MyProjectBanner extends StatelessWidget {
  const _MyProjectBanner({required this.result});

  final MyProjectResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final position = result.position;
    final (icon, color, text) = switch (position) {
      1 => (
          PhosphorIconsFill.trophy,
          _gold,
          '¡Tu proyecto «${result.projectName}» ganó la categoría ${result.categoryName}!'
        ),
      int p when p <= 3 => (
          PhosphorIconsFill.medal,
          medalColor(p),
          'Tu proyecto «${result.projectName}» quedó en el $p.° puesto de ${result.categoryName}.'
        ),
      int p => (
          PhosphorIconsRegular.medal,
          theme.colorScheme.primary,
          'Tu proyecto «${result.projectName}» quedó en el $p.° puesto de ${result.categoryName}.'
        ),
      null => (
          PhosphorIconsRegular.handHeart,
          theme.colorScheme.primary,
          '«${result.projectName}» no recibió votos del jurado esta vez. ¡Gracias por participar!'
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
    final rest = category.podium.where((p) => p.position != 1).toList();
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
            child: Text(category.name.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.2, fontWeight: FontWeight.w800)),
          ),
          if (winner == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m, 0, AppSpacing.m, AppSpacing.m),
              child: Text('Esta categoría no recibió votos del jurado.',
                  style: theme.textTheme.bodyMedium),
            )
          else
            _WinnerTile(entry: winner),
          for (final entry in rest) _PlaceTile(entry: entry),
          const SizedBox(height: AppSpacing.s),
        ],
      ),
    );
  }
}

class _WinnerTile extends StatelessWidget {
  const _WinnerTile({required this.entry});

  final PodiumEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.12),
        borderRadius: AppRadii.rMedium,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadii.rMedium,
            child: SizedBox(
              width: 64,
              height: 64,
              child: entry.coverUrl == null
                  ? const ColoredBox(
                      color: _gold,
                      child: Icon(PhosphorIconsFill.trophy,
                          color: Colors.white, size: 32),
                    )
                  : Image.network(entry.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                            color: _gold,
                            child: Icon(PhosphorIconsFill.trophy,
                                color: Colors.white, size: 32),
                          )),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(PhosphorIconsFill.trophy, color: _gold, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Text('GANADOR',
                      style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800, letterSpacing: 1)),
                ]),
                Text(entry.projectName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                if (entry.isMine) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const StatusChip(label: 'Tu proyecto', tone: AppTone.success),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.entry});

  final PodiumEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.m, AppSpacing.s, AppSpacing.m, 0),
      child: Row(
        children: [
          Icon(PhosphorIconsFill.medal,
              color: medalColor(entry.position), size: 22),
          const SizedBox(width: AppSpacing.s),
          Text('${entry.position}.°',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(entry.projectName, style: theme.textTheme.bodyMedium),
          ),
          if (entry.isMine)
            const StatusChip(label: 'Tu proyecto', tone: AppTone.success),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const pink = Color(0xFFE0457B);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: pink.withValues(alpha: 0.10),
        borderRadius: AppRadii.rLarge,
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsFill.heart, color: pink, size: 28),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FAVORITO DEL PÚBLICO',
                    style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800, letterSpacing: 1)),
                Text(name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                Text('El mejor calificado por los alumnos. No cambia el '
                    'resultado del jurado.',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
