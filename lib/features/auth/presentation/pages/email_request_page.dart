import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/campusvote_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/fade_slide.dart';
import '../state/auth_controller.dart';

/// Acceso del ESTUDIANTE: código de un solo uso enviado al correo.
///
/// El estudiante no gestiona contraseña: el backend responde a
/// `POST /api/auth/email/request` con un `tempToken` y el código llega al
/// correo; `EmailOtpVerifyPage` lo canjea por la sesión.
class EmailRequestPage extends ConsumerStatefulWidget {
  const EmailRequestPage({super.key});

  @override
  ConsumerState<EmailRequestPage> createState() => _EmailRequestPageState();
}

class _EmailRequestPageState extends ConsumerState<EmailRequestPage> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final ok = await ref
        .read(authControllerProvider.notifier)
        .requestEmailLogin(email: _emailCtrl.text);
    if (!mounted) return;
    if (ok) context.go('/auth/email-verify');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    const roleColor = AppColors.primary;

    return CampusVoteTheme(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: theme.textTheme.bodyLarge?.color),
            tooltip: 'Volver',
            onPressed: () => context.go('/splash'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
              bottom: AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.l),
                  FadeSlide(
                    delay: Duration.zero,
                    offset: 30,
                    child: Center(
                      // Pre-login la identidad es la de CampusVote, no la del
                      // tenant: se usa el logo del proyecto de Flutter.
                      child: AppLogo.asset(size: 88),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeSlide(
                    delay: const Duration(milliseconds: 100),
                    offset: 20,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.10),
                          borderRadius: AppRadii.rMedium,
                          border: Border.all(
                            color: roleColor.withValues(alpha: 0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school_rounded,
                                size: 16, color: roleColor),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Panel del Estudiante',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: roleColor,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  FadeSlide(
                    delay: const Duration(milliseconds: 150),
                    offset: 20,
                    child: Text(
                      'Ingresa con tu correo',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  FadeSlide(
                    delay: const Duration(milliseconds: 250),
                    offset: 20,
                    child: Text(
                      'Te enviaremos un código de 6 dígitos. No necesitas contraseña.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.75),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FadeSlide(
                    delay: const Duration(milliseconds: 350),
                    offset: 20,
                    child: AppTextField(
                      label: 'Correo institucional',
                      hint: 'tu.correo@universidad.edu',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailCtrl,
                      enabled: !state.submitting,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      prefixIcon: Icons.alternate_email_rounded,
                      validator: (value) {
                        final v = (value ?? '').trim();
                        if (v.isEmpty) {
                          return 'Escribe tu correo';
                        }
                        if (!_emailPattern.hasMatch(v)) {
                          return 'Escribe un correo válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.m),
                    FadeSlide(
                      delay: const Duration(milliseconds: 100),
                      offset: 10,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.08),
                          borderRadius: AppRadii.rMedium,
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.20),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.danger,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.danger,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  FadeSlide(
                    delay: const Duration(milliseconds: 450),
                    offset: 20,
                    child: AppButton(
                      label: 'Enviar código',
                      icon: Icons.mark_email_unread_outlined,
                      isLoading: state.submitting,
                      onPressed: state.submitting ? null : _submit,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  FadeSlide(
                    delay: const Duration(milliseconds: 500),
                    offset: 20,
                    child: TextButton(
                      onPressed: state.submitting
                          ? null
                          : () => context.go('/auth/jury/login'),
                      child: const Text('¿Eres jurado? Ingresa con contraseña'),
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
