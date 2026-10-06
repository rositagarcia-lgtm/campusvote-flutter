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
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/otp_code_field.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../domain/entities/totp.dart';
import '../state/auth_providers.dart';
import '../state/two_factor_controller.dart';
import '../widgets/totp_qr_card.dart';
import '../widgets/totp_secret_card.dart';
import '../../../settings/presentation/settings_copy.dart';

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
        SnackBar(
            content: Text(SettingsCopy.of(context).t('Ingresa los 6 dígitos'))),
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
        context.go('/security/totp/backup-codes', extra: data.backupCodes);
      },
      failure: (f) {
        setState(() => _verifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(SettingsCopy.of(context).error(f.message))),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: text.t('Configurar 2FA')),
      body: SafeArea(
        child: _loadingSetup
            ? AppLoader(message: text.t('Generando código QR...'))
            : _error != null
                ? AppErrorView(message: text.error(_error!), onRetry: _init)
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    children: [
                      NoticeBanner(
                        icon: Icons.info_outline_rounded,
                        tone: AppTone.info,
                        message: text.t(
                            'Escanea este QR con Google Authenticator, Microsoft Authenticator o similar.'),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      TotpQrCard(
                        qrCodeDataUrl: _setup!.qrCodeDataUrl,
                        uri: _setup!.uri,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      TotpSecretCard(secret: _setup!.secret),
                      const SizedBox(height: AppSpacing.l),
                      OtpCodeField(
                        controller: _codeCtrl,
                        label: text.t('Código de la aplicación'),
                        // Sin autofocus: primero hay que escanear el QR con el
                        // teléfono y el teclado taparía la imagen.
                        autofocus: false,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      AppButton(
                        label: text.t('Activar 2FA'),
                        icon: Icons.verified_user_rounded,
                        isLoading: _verifying,
                        onPressed: _verifying ? null : _verify,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      AppBadge(
                        label: text.t(
                            'Después de activar, en cada login el sistema te pedirá el OTP además de tu contraseña.'),
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
