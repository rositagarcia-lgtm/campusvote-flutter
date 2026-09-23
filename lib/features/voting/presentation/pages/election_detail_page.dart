import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../auth/presentation/pages/security_page.dart';
import '../../domain/entities/eligibility_status.dart';
import '../state/election_detail_controller.dart';
import '../widgets/election_status_badge.dart';

class ElectionDetailPage extends ConsumerWidget {
  final String electionId;

  const ElectionDetailPage({super.key, required this.electionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(electionDetailControllerProvider(electionId));

    ref.listen(electionDetailControllerProvider(electionId),
        (prev, next) {
      // carga inicial disparada por simulación post-frame
    });

    if (state.loading && state.election == null) {
      return Scaffold(
        appBar: buildCampusVoteAppBar(context, title: 'Cargando...'),
        body: const AppLoader(),
      );
    }

    if (state.errorMessage != null && state.election == null) {
      return Scaffold(
        appBar: buildCampusVoteAppBar(context),
        body: AppErrorView(
          message: state.errorMessage!,
          onRetry: () => ref
              .read(electionDetailControllerProvider(electionId).notifier)
              .load(),
        ),
      );
    }

    final election = state.election!;
    final df = DateFormat('dd MMM yyyy', 'es');
    final canVote = state.eligibility.state == VotingEligibility.eligible &&
        election.isOpen;

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: election.organizationName,
        actions: [
          IconButton(
            tooltip: 'Seguridad',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SecurityPage(),
              ),
            ),
            icon: const Icon(Icons.security_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadii.rLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            election.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        ElectionStatusBadge(election: election),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${df.format(election.startAt)} → ${df.format(election.endAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (election.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.m),
                      Text(election.description,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              _eligibilityBanner(context, state),
              const SizedBox(height: AppSpacing.l),
              AppButton(
                label: 'Iniciar votación',
                icon: Icons.how_to_vote_outlined,
                onPressed: canVote
                    ? () => context.go('/voting/${election.id}/ballot')
                    : null,
              ),
              const SizedBox(height: AppSpacing.m),
              if (!election.isOpen)
                Text(
                  'La elección no está abierta.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eligibilityBanner(BuildContext context, ElectionDetailState state) {
    final theme = Theme.of(context);
    final elig = state.eligibility;

    Color bg;
    Color fg;
    IconData icon;
    String text;

    switch (elig.state) {
      case VotingEligibility.eligible:
        bg = AppColors.successSoft;
        fg = AppColors.success;
        icon = Icons.check_circle_outline;
        text = 'Eres elegible para votar.';
        break;
      case VotingEligibility.alreadyVoted:
        bg = AppColors.warningSoft;
        fg = AppColors.warning;
        icon = Icons.history_rounded;
        text = 'Ya has emitido tu voto en esta elección.';
        break;
      case VotingEligibility.electionClosed:
        bg = AppColors.dangerSoft;
        fg = AppColors.danger;
        icon = Icons.lock_outline;
        text = 'La elección ya fue cerrada.';
        break;
      case VotingEligibility.electionNotStarted:
        bg = AppColors.infoSoft;
        fg = AppColors.info;
        icon = Icons.schedule_outlined;
        text = 'La elección aún no ha comenzado.';
        break;
      case VotingEligibility.notEligible:
        bg = AppColors.warningSoft;
        fg = AppColors.warning;
        icon = Icons.report_problem_outlined;
        text = 'No eres elegible para esta elección.';
        break;
      case VotingEligibility.sessionExpired:
        bg = AppColors.warningSoft;
        fg = AppColors.warning;
        icon = Icons.timer_off_outlined;
        text = 'Tu sesión de votación expiró.';
        break;
      case VotingEligibility.unknown:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.rMedium,
      ),
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(text,
                style: theme.textTheme.bodyMedium?.copyWith(color: fg)),
          ),
        ],
      ),
    );
  }
}