import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/role_landing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/auth_appbar.dart';
import '../../../../core/widgets/fade_slide.dart';
import '../../../../core/widgets/otp_code_field.dart';
import '../state/auth_controller.dart';
import '../widgets/auth_form_widgets.dart';

class TotpPage extends ConsumerStatefulWidget {
  const TotpPage({super.key});

  @override
  ConsumerState<TotpPage> createState() => _TotpPageState();
}

class _TotpPageState extends ConsumerState<TotpPage> {
  final _codeCtrl = TextEditingController();

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
        .verifyTotp(_codeCtrl.text);
    if (!mounted) return;
    if (ok) {
      // El destino sale del rol que devolvió el backend, no de una ruta fija.
      context
          .go(landingPathForRole(ref.read(authControllerProvider).user?.role));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryLighter : AppColors.primary;
    final error = state.errorMessage;

    return Scaffold(
      appBar: buildAuthAppBar(context, onBack: () => context.go('/splash')),
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
                      icon: Icons.security_rounded,
                      overline: 'Verificación en dos pasos',
                      title: 'Ingresa tu código',
                      subtitle:
                          'Ingresa el código de 6 dígitos de tu aplicación autenticadora.',
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
                          OtpCodeField(
                            controller: _codeCtrl,
                            label: 'Código de verificación',
                            onSubmitted: _submit,
                          ),
                          if (error != null) ...[
                            const SizedBox(height: AppSpacing.l),
                            AuthErrorBanner(message: error),
                          ],
                          const SizedBox(height: AppSpacing.l),
                          const AuthInfoNote(
                            icon: Icons.timer_outlined,
                            text:
                                'Usa el código vigente: tu aplicación lo renueva cada pocos segundos.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  FadeSlide(
                    delay: const Duration(milliseconds: 220),
                    child: AppButton(
                      label: 'Verificar',
                      icon: Icons.verified_outlined,
                      isLoading: state.submitting,
                      onPressed: state.submitting ? null : _submit,
                    ),
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
