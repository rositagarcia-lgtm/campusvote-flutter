import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';

/// `/jury/fair/:fairId/results` — ranking de la feria.
///
/// ATENCIÓN: `GET /fairs/:id/results` está restringido a ADMIN de la
/// organización (`fairResult.routes.js:27-31`, `MANAGERS = [ROLES.ADMIN]`).
/// Un usuario JURY recibe 403, así que esta pantalla solo puede mostrar datos
/// cuando el backend habilite el rol; hoy explica el bloqueo en vez de
/// fingir un ranking vacío.
class JuryResultsPage extends ConsumerWidget {
  const JuryResultsPage({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(fairResultsProvider(fairId));

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Resultados'),
      body: _bodyFor(results),
    );
  }
}

Widget _bodyFor(AsyncValue<FairResultsModel> results) {
  switch (results) {
    case AsyncLoading():
      return const AppLoader();
    case AsyncError(:final error):
      return _ResultsError(
        message: describeJuryError(error),
        onRetry: () => const SizedBox.shrink(),
      );
    case AsyncData(:final value):
      return _Ranking(results: value);
    default:
      return const AppLoader();
  }
}

class _ResultsError extends StatelessWidget {
  const _ResultsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorView(message: message, onRetry: onRetry);
  }
}

class _Ranking extends StatelessWidget {
  const _Ranking({required this.results});

  final FairResultsModel results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = results.ranking.where((e) => e.position != null).toList()
      ..sort((a, b) => a.position!.compareTo(b.position!));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        if (!results.published)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: AppRadii.rMedium,
            ),
            child: Text(
              'El organizer todavía no publica los resultados de esta feria.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (results.published) ...[
          Text(
            'Publicado el ${results.publishedAt?.toLocal() ?? ''}'
            '${results.publishedByName != null ? ' por ${results.publishedByName}' : ''}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        for (final entry in entries) ...[
          _RankTile(entry: entry),
          const SizedBox(height: AppSpacing.s),
        ],
      ],
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({required this.entry});

  final FairResultEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: entry.winner
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
        borderRadius: AppRadii.rMedium,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                entry.winner ? theme.colorScheme.primary : theme.dividerColor,
            child: Text(
              '${entry.position}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: entry.winner
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              entry.name,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text('${entry.votes} voto${entry.votes == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
