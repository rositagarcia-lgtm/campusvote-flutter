import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../state/ballot_controller.dart';
import '../widgets/vote_summary.dart';

class VoteConfirmationPage extends ConsumerWidget {
  final String electionId;

  const VoteConfirmationPage({super.key, required this.electionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ballotControllerProvider(electionId));
    final ballot = state.ballot;

    if (ballot == null) {
      return Scaffold(
        appBar: buildCampusVoteAppBar(context, title: 'Confirmar'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Confirmar voto'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            VoteSummary(
              positions: ballot.positions,
              selections: state.selections,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              label: 'Confirmar voto',
              icon: Icons.check_rounded,
              onPressed: () => context.go(
                '/voting/$electionId/success',
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            AppButton.outlined(
              label: 'Volver y editar',
              icon: Icons.edit_rounded,
              onPressed: () => context.go('/voting/$electionId/ballot'),
            ),
          ],
        ),
      ),
    );
  }
}