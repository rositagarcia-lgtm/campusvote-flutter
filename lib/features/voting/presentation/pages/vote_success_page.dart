import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../domain/entities/voting_session.dart';
import '../state/ballot_controller.dart';
import '../state/voting_providers.dart';
import '../widgets/confirm_vote_dialog.dart';

class VoteSuccessPage extends ConsumerStatefulWidget {
  final String electionId;

  const VoteSuccessPage({super.key, required this.electionId});

  @override
  ConsumerState<VoteSuccessPage> createState() => _VoteSuccessPageState();
}

class _VoteSuccessPageState extends ConsumerState<VoteSuccessPage> {
  bool _busy = false;
  bool _submitting = false; // anti-doble-submit

  Future<void> _submit() async {
    if (_submitting) return;
    final confirm = await ConfirmVoteDialog.show(context);
    if (!confirm || !mounted) return;

    setState(() {
      _busy = true;
      _submitting = true;
    });

    final state = ref.read(ballotControllerProvider(widget.electionId));
    final ctrl =
        ref.read(ballotControllerProvider(widget.electionId).notifier);

    final sessionId = state.sessionId ?? await _ensureSession();
    if (sessionId == null) {
      _resetSubmit();
      return;
    }

    final result = await ref.read(castVoteUseCaseProvider)(
      sessionId: sessionId,
      optionIds: ctrl.allSelectedOptionIds(),
      rawSelections: ctrl.selectionsPayload(),
    );

    if (!mounted) return;
    result.when(
      success: (receipt) {
        // Navega al comprobante con el código real devuelto por el backend.
        context.go(
          '/voting/${widget.electionId}/receipt/${receipt.receiptCode}',
        );
      },
      failure: (f) {
        _resetSubmit();
        AppDialog.info(
          context,
          title: 'No se pudo registrar el voto',
          message: f.message,
        );
      },
    );
  }

  void _resetSubmit() {
    if (mounted) {
      setState(() {
      _busy = false;
      _submitting = false;
    });
    }
  }

  Future<String?> _ensureSession() async {
    final res = await ref.read(createVotingSessionUseCaseProvider)(
      widget.electionId,
    );
    String? id;
    res.when(
      success: (VotingSession? s) {
        id = s?.sessionId;
      },
      failure: (f) {
        AppDialog.info(
          context,
          title: 'Sesión no disponible',
          message: f.message,
        );
      },
    );
    return id;
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return Scaffold(
        appBar: buildCampusVoteAppBar(context, title: 'Enviando voto'),
        body: const AppLoader(message: 'Registrando tu voto...'),
      );
    }
    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Enviar voto'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const Icon(Icons.cloud_upload_outlined,
                  size: 64, color: Color(0xFF00695C)),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Listo para enviar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Confirma tu voto para emitirlo oficialmente. Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              AppButton(
                label: 'Enviar voto',
                icon: Icons.lock_rounded,
                onPressed: _submitting ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.m),
              AppButton.outlined(
                label: 'Volver',
                onPressed: () =>
                    context.go('/voting/${widget.electionId}/confirmation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}