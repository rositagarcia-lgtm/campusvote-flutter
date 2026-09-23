import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/entities/totp.dart';
import '../state/auth_providers.dart';
import '../state/two_factor_controller.dart';
import '../widgets/totp_code_input.dart';
import '../widgets/totp_qr_card.dart';
import '../widgets/totp_secret_card.dart';

class TotpSetupPage extends ConsumerStatefulWidget {
  const TotpSetupPage({super.key});

  @override
  ConsumerState<TotpSetupPage> createState() => _TotpSetupPageState();
}

class _TotpSetupPageState extends ConsumerState<TotpSetupPage> {
  bool _loadingSetup = true;
  TotpSetup? _setup;
  String? _error;
  bool _verifying = false;
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loadingSetup = true;
      _error = null;
    });
    final res = await ref.read(setupTotpUseCaseProvider)();
    if (!mounted) return;
    res.when(
      success: (data) {
        setState(() {
          _setup = data;
          _loadingSetup = false;
        });
      },
      failure: (f) {
        setState(() {
          _error = f.message;
          _loadingSetup = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa los 6 dígitos')),
      );
      return;
    }
    setState(() => _verifying = true);
    final res = await ref.read(verifyAndEnableTotpUseCaseProvider)(code);
    if (!mounted) return;
    res.when(
      success: (data) {
        ref.read(twoFactorControllerProvider.notifier).markEnabled();
        setState(() => _verifying = false);
        context.go('/security/totp/backup-codes',
            extra: data.backupCodes);
      },
      failure: (f) {
        setState(() => _verifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Configurar 2FA'),
      body: SafeArea(
        child: _loadingSetup
            ? const AppLoader(message: 'Generando código QR...')
            : _error != null
                ? AppErrorView(message: _error!, onRetry: _init)
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: const BoxDecoration(
                          color: AppColors.infoSoft,
                          borderRadius: AppRadii.rMedium,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppColors.info),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: Text(
                                'Escanea este QR con Google Authenticator, '
                                'Microsoft Authenticator o similar.',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.info),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      TotpQrCard(
                        qrCodeDataUrl: _setup!.qrCodeDataUrl,
                        uri: _setup!.uri,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      TotpSecretCard(secret: _setup!.secret),
                      const SizedBox(height: AppSpacing.l),
                      Text('Verifica el código',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.s),
                      TotpCodeInput(controller: _codeCtrl),
                      const SizedBox(height: AppSpacing.l),
                      AppButton(
                        label: 'Activar 2FA',
                        icon: Icons.verified_user_rounded,
                        isLoading: _verifying,
                        onPressed: _verifying ? null : _verify,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      const AppBadge(
                        label:
                            'Después de activar, en cada login el sistema te pedirá el OTP además de tu contraseña.',
                        background: AppColors.primarySoft,
                        foreground: AppColors.primary,
                        icon: Icons.lock_outline,
                      ),
                    ],
                  ),
      ),
    );
  }
}