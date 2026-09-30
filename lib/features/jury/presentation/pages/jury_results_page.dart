import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_status_chip.dart';
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
    final reload = ref.read(fairResultsProvider(fairId).notifier).reload;

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Resultados'),
      body: _bodyFor(results, reload),
    );
  }
}

Widget _bodyFor(
  AsyncValue<FairResultsModel> results,
  VoidCallback onRetry,
) {
  switch (results) {
    case AsyncLoading():
      return const AppLoader();
    case AsyncError(:final error):
      return AppErrorView(
        message: describeJuryError(error),
        onRetry: onRetry,
      );
    case AsyncData(:final value):
      return _Ranking(results: value);
    default:
      return const AppLoader();
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

    return PageScrollBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!results.published)
            const NoticeBanner(
              message:
                  'El organizer todavía no publica los resultados de esta feria.',
              tone: AppTone.warning,
            ),
          if (results.published) ...[
            Text(
              'Publicado el ${results.publishedAt?.toLocal() ?? ''}'
              '${results.publishedByName != null ? ' por ${results.publishedByName}' : ''}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          if (entries.isEmpty)
            const NoticeBanner(
              message: 'Todavía no hay puestos publicados para esta feria.',
              tone: AppTone.info,
              liveRegion: true,
            ),
          for (final entry in entries) ...[
            _RankTile(entry: entry),
            const SizedBox(height: AppSpacing.s),
          ],
        ],
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({required this.entry});

  final FairResultEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      color: entry.winner ? theme.colorScheme.primaryContainer : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          _PositionBadge(entry: entry),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              entry.name,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          StatusChip(
            label: '${entry.votes} voto${entry.votes == 1 ? '' : 's'}',
            tone: entry.winner ? AppTone.primary : AppTone.neutral,
          ),
        ],
      ),
    );
  }
}

/// Círculo con la posición; el ganador se marca además con tono primario para
/// que el estado no dependa solo del número.
class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.entry});

  final FairResultEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final winner = entry.winner;

    return Semantics(
      label: 'Puesto ${entry.position}${winner ? ', ganador' : ''}',
      excludeSemantics: true,
      child: Container(
        width: AppDimensions.iconLarge * 1.5,
        height: AppDimensions.iconLarge * 1.5,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: winner ? theme.colorScheme.primary : theme.dividerColor,
        ),
        child: Text(
          '${entry.position}',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: winner ? theme.colorScheme.onPrimary : null,
          ),
        ),
      ),
    );
  }
}
