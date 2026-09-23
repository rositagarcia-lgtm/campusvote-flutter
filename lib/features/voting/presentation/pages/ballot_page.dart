import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../state/ballot_controller.dart';
import '../widgets/ballot_progress.dart';
import '../widgets/candidate_card.dart';
import '../widgets/position_card.dart';

class BallotPage extends ConsumerStatefulWidget {
  final String electionId;

  const BallotPage({super.key, required this.electionId});

  @override
  ConsumerState<BallotPage> createState() => _BallotPageState();
}

class _BallotPageState extends ConsumerState<BallotPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ballotControllerProvider(widget.electionId).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ballotControllerProvider(widget.electionId));
    final ctrl = ref.read(ballotControllerProvider(widget.electionId).notifier);

    if (state.loading && state.ballot == null) {
      return Scaffold(
        appBar: buildCampusVoteAppBar(context, title: 'Boleta'),
        body: const AppLoader(),
      );
    }
    if (state.errorMessage != null && state.ballot == null) {
      return Scaffold(
        appBar: buildCampusVoteAppBar(context, title: 'Boleta'),
        body: AppErrorView(
          message: state.errorMessage!,
          onRetry: ctrl.load,
        ),
      );
    }

    final ballot = state.ballot!;
    final selectedCount = state.selections.values
        .where((l) => l.isNotEmpty)
        .length;

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Boleta'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.l),
                children: [
                  BallotProgress(
                    current: selectedCount,
                    total: ballot.positions.length,
                    label: 'Cargos completados',
                  ),
                  const SizedBox(height: AppSpacing.l),
                  for (final pos in ballot.positions) ...[
                    PositionCard(
                      name: pos.position.name,
                      description: pos.position.description,
                      seats: pos.position.seats,
                      child: Column(
                        children: [
                          for (final opt in pos.options)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.s),
                              child: CandidateCard(
                                option: opt,
                                selected: state.isSelected(pos.id, opt.id),
                                onChanged: (_) {
                                  ctrl.toggleOption(pos.id, opt.id,
                                      single: pos.position.seats == 1);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: AppButton(
                  label: 'Revisar mi voto',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: state.isComplete
                      ? () => context.go(
                            '/voting/${widget.electionId}/confirmation',
                          )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}