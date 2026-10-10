import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_palette.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../widgets/auth_form_widgets.dart';
import '../../../settings/presentation/settings_copy.dart';

class TotpBackupCodesPage extends ConsumerWidget {
  final List<String> backupCodes;
  const TotpBackupCodesPage({super.key, required this.backupCodes});

  Future<void> _copyAll(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: backupCodes.join('\n')));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(SettingsCopy.of(context).t('Códigos copiados'))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = context.brandPrimary;
    final muted = appMuted(isDark);
    final text = SettingsCopy.of(context);

    return Scaffold(
      appBar:
          buildCampusVoteAppBar(context, title: text.t('Códigos de respaldo')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NoticeBanner(
                    tone: AppTone.warning,
                    liveRegion: true,
                    message: text.t(
                        'Guarda estos códigos en un lugar seguro. Los necesitarás si pierdes acceso a tu aplicación autenticadora.'),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AuthFormCard(
                    accent: accent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          text.backupCodes(backupCodes.length),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: backupCodes.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 52,
                            crossAxisSpacing: AppSpacing.s,
                            mainAxisSpacing: AppSpacing.s,
                          ),
                          itemBuilder: (_, i) => _CodeTile(
                            index: i + 1,
                            code: backupCodes[i],
                            accent: accent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.l),
                        AppButton.outlined(
                          label: text.t('Copiar todos'),
                          icon: PhosphorIconsRegular.copy,
                          onPressed: () => _copyAll(context),
                        ),
                        const SizedBox(height: AppSpacing.l),
                        AuthInfoNote(
                          icon: PhosphorIconsRegular.lockSimple,
                          text: text.t(
                              'Guárdalos fuera de tu teléfono, por ejemplo impresos o en un gestor de contraseñas.'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppButton(
                    label: text.t('He guardado mis códigos'),
                    icon: PhosphorIconsBold.check,
                    onPressed: () => context.go('/security'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Un código de respaldo numerado, seleccionable y en tipografía monoespaciada.
class _CodeTile extends StatelessWidget {
  const _CodeTile({
    required this.index,
    required this.code,
    required this.accent,
  });

  final int index;
  final String code;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = appMuted(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: AppRadii.rMedium,
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Text(
            index.toString().padLeft(2, '0'),
            style: theme.textTheme.labelSmall?.copyWith(color: muted),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: SelectableText(
              code,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
