import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_appbar.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_notice.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../data/fair_audience_repository.dart';
import '../domain/audience_models.dart';
import 'audience_widgets.dart';
import 'rate_project_sheet.dart';

/// `/teaching/explore/:fairId` — proyectos aprobados de la feria. El alumno
/// abre uno para calificarlo y dejar un comentario de mejora.
class AudienceProjectsPage extends ConsumerWidget {
  const AudienceProjectsPage({
    super.key,
    required this.fairId,
  });

  final String fairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(audienceBoardProvider(fairId));
    Future<void> reload() => ref.refresh(audienceBoardProvider(fairId).future);

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: board.valueOrNull?.fair.name ?? 'Proyectos de la feria',
        leading: IconButton(
          tooltip: 'Volver a las ferias',
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.go('/teaching/explore'),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: reload,
        child: board.when(
          loading: () => const AppLoader(),
          error: (error, _) => AppErrorView(
            message: mapExceptionToFailure(error).message,
            onRetry: reload,
          ),
          data: (data) => _Board(
            fairId: fairId,
            board: data,
          ),
        ),
      ),
    );
  }
}

class _Board extends ConsumerStatefulWidget {
  const _Board({
    required this.fairId,
    required this.board,
  });

  final String fairId;
  final AudienceBoard board;

  @override
  ConsumerState<_Board> createState() => _BoardState();
}

class _BoardState extends ConsumerState<_Board> {
  String get fairId => widget.fairId;
  AudienceBoard get board => widget.board;

  Future<void> _open(
      BuildContext context, WidgetRef ref, AudienceProject project) async {
    final saved = await showRateProjectSheet(
      context,
      fairId: fairId,
      project: project,
      canRate: board.fair.isOpen,
    );
    if (saved == true) {
      ref.invalidate(audienceBoardProvider(fairId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Gracias! Tu opinión quedó guardada.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorite = board.favorite;
    final rated = board.projects.where((p) => p.myScore != null).length;
    final rateable = board.projects.where((p) => !p.isMine).length;

    if (board.projects.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          AppEmptyView(
            icon: PhosphorIconsRegular.storefront,
            overline: 'PROYECTOS',
            title: 'Aún no hay proyectos aprobados',
            message: 'Vuelve más tarde para conocer los proyectos de la feria.',
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        if (favorite != null) ...[
          AppMotion.reveal(0, FavoriteBanner(project: favorite)),
          const SizedBox(height: AppSpacing.m),
        ],
        NoticeBanner(
          tone: board.fair.isOpen ? AppTone.primary : AppTone.neutral,
          icon: board.fair.isOpen
              ? PhosphorIconsRegular.star
              : PhosphorIconsRegular.lockSimple,
          message: board.fair.isOpen
              ? 'Calificaste $rated de $rateable proyectos. El equipo del proyecto ve tu nombre. Tu voto no cuenta para la nota del jurado.'
              : 'La feria cerró: las opiniones quedaron congeladas.',
        ),
        const SizedBox(height: AppSpacing.l),
        for (var i = 0; i < board.projects.length; i++)
          AppMotion.reveal(
            i + 1,
            AudienceProjectCard(
              project: board.projects[i],
              minVotes: board.minVotes,
              canRate: board.fair.isOpen,
              isFavorite: board.projects[i].id == board.favoriteProjectId,
              onTap: () => _open(context, ref, board.projects[i]),
            ),
          ),
      ],
    );
  }
}
