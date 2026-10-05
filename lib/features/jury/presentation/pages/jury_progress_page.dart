import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../data/models/jury_models.dart';
import '../providers/jury_providers.dart';
import '../widgets/jury_progress_bar.dart';
import '../../../settings/presentation/settings_copy.dart';

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
    final reload = ref.read(juryProgressProvider(fairId).notifier).reload;

    return Scaffold(
      appBar: buildCampusVoteAppBar(context,
          title: SettingsCopy.of(context).t('Mi progreso')),
      body: RefreshIndicator(
        onRefresh: reload,
        child: _bodyFor(fairId, progress, reload),
      ),
    );
  }
}

Widget _bodyFor(
  String fairId,
  AsyncValue<JuryProgressModel> progress,
  VoidCallback onRetry,
) {
  switch (progress) {
    case AsyncLoading():
      return const AppLoader();
    case AsyncError(:final error):
      return AppErrorView(
        message: describeJuryError(error),
        onRetry: onRetry,
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
    final signed = progress.declaration != null;
    final text = SettingsCopy.of(context);

    return PageScrollBody(
      // Siempre desplazable para que el pull-to-refresh funcione con poco
      // contenido.
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (progress.fairName != null) ...[
            Text(
              progress.fairName!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'serif',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
          AppCard(
            child: JuryProgressBar(
              completed: progress.completedProjects,
              total: progress.totalProjects,
              percentage: progress.progressPercentage,
              label: text.t('Evaluaciones finalizadas'),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          _StatusRow(
            icon: progress.hasVoted
                ? Icons.how_to_vote_rounded
                : Icons.pending_actions_rounded,
            title: text.t('Votación'),
            value: progress.hasVoted
                ? text.t('Voto emitido')
                : text.t('Pendiente'),
            done: progress.hasVoted,
          ),
          const SizedBox(height: AppSpacing.s),
          _StatusRow(
            icon: signed
                ? Icons.assignment_turned_in_rounded
                : Icons.assignment_rounded,
            title: text.t('Declaración de jurado'),
            value: signed ? text.t('Firmada') : text.t('Sin firmar'),
            done: signed,
          ),
          if (signed) ...[
            const SizedBox(height: AppSpacing.l),
            SectionHeader(label: text.t('Declaración registrada')),
            AppCard(
              child: Text(
                progress.declaration!.statement,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          AppButton.outlined(
            label: signed
                ? text.t('Ver mi declaración')
                : text.t('Firmar declaración de jurado'),
            icon: signed ? Icons.description_outlined : Icons.draw_outlined,
            onPressed: () => context.push('/jury/fair/$fairId/declaration'),
          ),
        ],
      ),
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
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconMedium,
            color: done ? theme.colorScheme.primary : theme.disabledColor,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
          StatusChip(
            label: value,
            tone: done ? AppTone.primary : AppTone.neutral,
          ),
        ],
      ),
    );
  }
}
