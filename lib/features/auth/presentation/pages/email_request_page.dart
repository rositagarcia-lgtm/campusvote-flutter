import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/branding_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../state/auth_controller.dart';

/// Paso 1 del acceso sin contraseña: solicita el correo.
///
/// El backend resuelve la organización a partir del correo y devuelve el
/// branding + tempToken EMAIL_PENDING que llevan al paso 2 (código OTP).
class EmailRequestPage extends ConsumerStatefulWidget {
  const EmailRequestPage({super.key});

  @override
  ConsumerState<EmailRequestPage> createState() => _EmailRequestPageState();
}

class _EmailRequestPageState extends ConsumerState<EmailRequestPage> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).requestEmailLogin(
          email: _emailCtrl.text,
        );
    if (!mounted) return;
    if (ok) {
      context.go('/auth/email-verify');
    }
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
          onPressed: () => context.go('/splash'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: AppLogo.organization(
                    logoUrl: branding.logoUrl,
                    organizationCode: branding.name,
                    size: 72,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Ingresa con tu correo',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Te enviaremos un código de acceso único a tu correo. No necesitas contraseña.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppTextField(
                  label: 'Correo',
                  hint: 'tu.correo@universidad.edu',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailCtrl,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  prefixIcon: Icons.alternate_email_rounded,
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Escribe tu correo';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                      return 'Escribe un correo válido';
                    }
                    return null;
                  },
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: const BoxDecoration(
                      color: AppColors.dangerSoft,
                      borderRadius: AppRadii.rMedium,
                    ),
                    child: Text(
                      state.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Enviar código',
                  icon: Icons.mark_email_unread_outlined,
                  isLoading: state.submitting,
                  onPressed: state.submitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}