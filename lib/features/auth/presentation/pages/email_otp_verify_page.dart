import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../state/auth_controller.dart';

/// Paso 2 del acceso sin contraseña: verifica el código enviado al correo.
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
    if (_codeCtrl.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un código de 6 dígitos')),
      );
      return;
    }
    final ok = await ref
        .read(authControllerProvider.notifier)
        .verifyEmailLogin(_codeCtrl.text);
    if (!mounted) return;
    if (ok) {
      // El router re-dirige por rol (JURY → ferias asignadas,
      // STUDENT → evaluación docente).
      context.go('/teaching');
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    final ok = await ref
        .read(authControllerProvider.notifier)
        .resendEmailLogin();
    if (!mounted) return;
    setState(() => _resending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Te enviamos un nuevo código' : 'Espera un minuto y vuelve a intentar',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final branding = ref.watch(brandingControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/auth/email-request'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.l),
              Center(
                child: AppLogo.organization(
                  logoUrl: branding.logoUrl,
                  organizationCode: branding.name,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Verifica tu correo',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Ingresa el código de 6 dígitos que enviamos a tu correo.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              if (state.pendingEmail != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  state.pendingEmail!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 12,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(hintText: '000000'),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Verificar',
                icon: Icons.verified_outlined,
                isLoading: state.submitting,
                onPressed: state.submitting ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.l),
              AppButton.outlined(
                label: 'Reenviar código',
                icon: Icons.refresh_rounded,
                isLoading: _resending,
                onPressed: _resending || state.submitting ? null : _resend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}