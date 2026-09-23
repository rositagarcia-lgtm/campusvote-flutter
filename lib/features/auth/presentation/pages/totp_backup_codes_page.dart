import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class TotpBackupCodesPage extends ConsumerWidget {
  final List<String> backupCodes;
  const TotpBackupCodesPage({super.key, required this.backupCodes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Códigos de respaldo'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: const BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: AppRadii.rMedium,
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      'Guarda estos códigos en un lugar seguro. Los necesitarás '
                      'si pierdes acceso a tu aplicación autenticadora.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: AppSpacing.s,
                    mainAxisSpacing: AppSpacing.s,
                    children: [
                      for (final c in backupCodes)
                        Container(
                          alignment: Alignment.center,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: AppRadii.rMedium,
                            border: Border.all(
                              color:
                                  AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: SelectableText(
                            c,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: 'monospace',
                              letterSpacing: 1.2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.outlined(
                          label: 'Copiar todos',
                          icon: Icons.copy_rounded,
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: backupCodes.join('\n')),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Códigos copiados')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              label: 'He guardado mis códigos',
              icon: Icons.check_rounded,
              onPressed: () => context.go('/security'),
            ),
          ],
        ),
      ),
    );
  }
}