import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../state/voting_list_controller.dart';
import '../widgets/election_card.dart';
import '../widgets/election_skeletons.dart';

class VotingHomePage extends ConsumerStatefulWidget {
  const VotingHomePage({super.key});

  @override
  ConsumerState<VotingHomePage> createState() => _VotingHomePageState();
}

class _VotingHomePageState extends ConsumerState<VotingHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(votingListControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(votingListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusVote'),
        actions: [
          IconButton(
            onPressed: () => ref.read(votingListControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Seguridad',
            onPressed: () => context.push('/security'),
            icon: const Icon(Icons.security_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(votingListControllerProvider.notifier).refresh(),
          child: _buildBody(state),
        ),
      ),
    );
  }

  Widget _buildBody(VotingListState state) {
    if (state.loading && state.isEmpty) {
      return const ElectionListSkeleton();
    }
    if (state.errorMessage != null && state.isEmpty) {
      return AppErrorView(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(votingListControllerProvider.notifier).load(),
      );
    }
    if (state.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                const Icon(Icons.how_to_vote_outlined, size: 64),
                const SizedBox(height: AppSpacing.m),
                Text(
                  'No hay elecciones disponibles',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Cuando existan elecciones activas en tu organización aparecerán aquí.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        if (state.active.isNotEmpty) ...[
          const AppSectionTitle(
            title: 'Elecciones activas',
            subtitle: 'Puedes votar ahora',
          ),
          const SizedBox(height: AppSpacing.m),
          for (final e in state.active) ...[
            ElectionCard(
              election: e,
              onTap: () => context.go('/voting/${e.id}'),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ],
        if (state.upcoming.isNotEmpty) ...[
          const AppSectionTitle(
            title: 'Próximas elecciones',
            subtitle: 'Aún no disponibles',
          ),
          const SizedBox(height: AppSpacing.m),
          for (final e in state.upcoming) ...[
            ElectionCard(
              election: e,
              onTap: () => context.go('/voting/${e.id}'),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ],
        if (state.closed.isNotEmpty) ...[
          const AppSectionTitle(
            title: 'Finalizadas',
            subtitle: 'Votación cerrada',
          ),
          const SizedBox(height: AppSpacing.m),
          for (final e in state.closed) ...[
            ElectionCard(
              election: e,
              onTap: () => context.go('/voting/${e.id}'),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ],
      ],
    );
  }
}