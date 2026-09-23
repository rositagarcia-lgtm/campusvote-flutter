import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../state/receipt_view_controller.dart';
import '../widgets/receipt_card.dart';

class VotingReceiptPage extends ConsumerWidget {
  final String electionId;
  final String receiptCode;

  const VotingReceiptPage({
    super.key,
    required this.electionId,
    required this.receiptCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(receiptViewControllerProvider((
      electionId: electionId,
      receiptCode: receiptCode,
    )));

    final body = state.loading
        ? const AppLoader(message: 'Verificando comprobante...')
        : (state.errorMessage != null && state.receipt.castAt == null)
            ? AppErrorView(message: state.errorMessage!)
            : SingleChildScrollView(
                child: ReceiptCard(
                  electionTitle:
                      state.receipt.electionTitle ?? 'Elección',
                  receipt: state.receipt,
                  castAt: state.receipt.castAt ?? DateTime.now(),
                ),
              );

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Comprobante'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: body),
              AppButton(
                label: 'Volver al inicio',
                icon: Icons.home_rounded,
                onPressed: () => context.go('/voting'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}