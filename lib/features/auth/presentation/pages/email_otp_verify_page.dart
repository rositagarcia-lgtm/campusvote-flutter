import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/routing/role_landing.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/auth_appbar.dart';
import '../../../../core/widgets/fade_slide.dart';
import '../../../../core/widgets/otp_code_field.dart';
import '../state/auth_controller.dart';
import '../widgets/auth_form_widgets.dart';
import '../widgets/email_otp_widgets.dart';
import '../../../settings/presentation/settings_copy.dart';

/// Paso 2 del acceso por correo para estudiantes y jurados habilitados.
class EmailOtpVerifyPage extends ConsumerStatefulWidget {
  const EmailOtpVerifyPage({super.key});

  @override
  ConsumerState<EmailOtpVerifyPage> createState() => _EmailOtpVerifyPageState();
}

class _EmailOtpVerifyPageState extends ConsumerState<EmailOtpVerifyPage> {
  final _codeCtrl = TextEditingController();
  bool _resending = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(authControllerProvider).submitting || _resending) return;
    if (_codeCtrl.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                SettingsCopy.of(context).t('Ingresa un código de 6 dígitos'))),
      );
      return;
    }
    final ok = await ref
        .read(authControllerProvider.notifier)
        .verifyEmailLogin(_codeCtrl.text);
    if (!mounted) return;
    if (ok) {
      // El destino sale del rol que devolvió el backend, no de una ruta fija.
      context
          .go(landingPathForRole(ref.read(authControllerProvider).user?.role));
    }
  }

  Future<void> _resend() async {
    if (_resending || ref.read(authControllerProvider).submitting) return;
    setState(() => _resending = true);
    final ok =
        await ref.read(authControllerProvider.notifier).resendEmailLogin();
    if (!mounted) return;
    setState(() => _resending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? SettingsCopy.of(context).t('Te enviamos un nuevo código')
              : SettingsCopy.of(context).t('No se pudo reenviar el código'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final currentTheme = Theme.of(context);
    final theme = currentTheme.brightness == Brightness.dark
        ? AppTheme.dark()
        : AppTheme.light();
    final accent = theme.colorScheme.primary;
    final error = state.errorMessage == null
        ? null
        : SettingsCopy.of(context).error(state.errorMessage!);
    final email = state.pendingEmail;
    final qrCode = state.pendingQrCode;
    final text = SettingsCopy.of(context);

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: buildAuthAppBar(
          context,
          onBack: () => context.go('/splash'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.l),
              child: Center(
                child: AuthAppBarBadge(
                  accent: accent,
                  label: text.t('Paso 2 de 2'),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlide(
                      child: AuthHeader(
                        accent: accent,
                        icon: PhosphorIconsRegular.shieldCheck,
                        overline: text.t('Verificaci\u00f3n segura'),
                        title: text.t('Verifica tu correo'),
                        subtitle: text.t(
                          'Ingresa el c\u00f3digo de 6 d\u00edgitos enviado al correo asociado a tu acceso.',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeSlide(
                      delay: const Duration(milliseconds: 120),
                      child: AuthFormCard(
                        accent: accent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (email != null) ...[
                              SentToEmailRow(email: email, accent: accent),
                              const SizedBox(height: AppSpacing.l),
                            ],
                            OtpCodeField(
                              controller: _codeCtrl,
                              label: text.t('Código de verificación'),
                              segmented: true,
                              enabled: !state.submitting && !_resending,
                              onSubmitted: _submit,
                            ),
                            if (error != null) ...[
                              const SizedBox(height: AppSpacing.l),
                              AuthErrorBanner(message: error),
                            ],
                            const SizedBox(height: AppSpacing.l),
                            NoticeBanner(
                              tone: AppTone.warning,
                              icon: PhosphorIconsRegular.envelopeSimpleOpen,
                              message: text.t(
                                '\u00bfNo encuentras el correo? Revisa tu carpeta de spam o correo no deseado.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    FadeSlide(
                      delay: const Duration(milliseconds: 220),
                      child: AppButton(
                        label: text.t('Verificar'),
                        icon: PhosphorIconsRegular.sealCheck,
                        isLoading: state.submitting,
                        onPressed: state.submitting ? null : _submit,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    FadeSlide(
                      delay: const Duration(milliseconds: 300),
                      child: AppButton.outlined(
                        label: text.t('Reenviar código'),
                        icon: PhosphorIconsRegular.arrowClockwise,
                        isLoading: _resending,
                        onPressed:
                            _resending || state.submitting ? null : _resend,
                      ),
                    ),
                    // Segunda vía de verificación: solo aparece si el backend
                    // devolvió un QR en el paso anterior.
                    if (qrCode != null) ...[
                      const SizedBox(height: AppSpacing.l),
                      FadeSlide(
                        delay: const Duration(milliseconds: 380),
                        child:
                            EmailOtpQrOption(dataUrl: qrCode, accent: accent),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Semantics(
                      label: text.t(
                        'El c\u00f3digo es personal y de un solo uso. No lo compartas.',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIconsRegular.shield,
                            size: AppDimensions.iconSmall,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Flexible(
                            child: Text(
                              text.t(
                                'El c\u00f3digo es personal y de un solo uso. No lo compartas.',
                              ),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
