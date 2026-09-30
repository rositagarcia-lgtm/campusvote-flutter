import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import '../widgets/jury_progress_bar.dart';

/// `/jury/fair/:fairId/progress` — avance del jurado y su declaración.
///
/// Carga `GET /fairs/my-progress/:fairId`, que ya resume todo: totales,
/// porcentaje, si firmó la declaración y si votó.
class JuryProgressPage extends ConsumerWidget {
  const JuryProgressPage({super.key, required this.fairId});

  final String fairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(juryProgressProvider(fairId));

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Mi progreso'),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(juryProgressProvider(fairId).notifier).reload(),
        child: _bodyFor(fairId, progress),
      ),
    );
  }
}

Widget _bodyFor(String fairId, AsyncValue<JuryProgressModel> progress) {
  switch (progress) {
    case AsyncLoading():
      return const AppLoader();
    case AsyncError(:final error):
      return AppErrorView(
        message: describeJuryError(error),
        onRetry: () => const AppLoader(),
      );
    case AsyncData(:final value):
      return _ProgressBody(fairId: fairId, progress: value);
    default:
      return const AppLoader();
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.fairId, required this.progress});

  final String fairId;
  final JuryProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        if (progress.fairName != null) ...[
          Text(
            progress.fairName!,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: JuryProgressBar(
              completed: progress.completedProjects,
              total: progress.totalProjects,
              percentage: progress.progressPercentage,
              label: 'Evaluaciones finalizadas',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        _StatusRow(
          icon: progress.hasVoted
              ? Icons.how_to_vote_rounded
              : Icons.pending_actions_rounded,
          title: 'Votación',
          value: progress.hasVoted ? 'Voto emitido' : 'Pendiente',
          done: progress.hasVoted,
        ),
        const SizedBox(height: AppSpacing.s),
        _StatusRow(
          icon: progress.declaration != null
              ? Icons.assignment_turned_in_rounded
              : Icons.assignment_rounded,
          title: 'Declaración de jurado',
          value: progress.declaration != null ? 'Firmada' : 'Sin firmar',
          done: progress.declaration != null,
        ),
        const SizedBox(height: AppSpacing.l),
        if (progress.declaration != null) ...[
          Text(
            'Declaración registrada',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: AppRadii.rMedium,
            ),
            child: Text(
              progress.declaration!.statement,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        FilledButton.tonal(
          onPressed: () => context.push('/jury/fair/$fairId/declaration'),
          child: Text(
            progress.declaration != null
                ? 'Ver mi declaración'
                : 'Firmar declaración de jurado',
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.done,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.rMedium,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: done ? theme.colorScheme.primary : theme.disabledColor,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: done ? theme.colorScheme.primary : theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
