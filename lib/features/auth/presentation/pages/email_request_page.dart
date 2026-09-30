import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/campusvote_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/fade_slide.dart';
import '../state/auth_controller.dart';
import '../widgets/auth_form_widgets.dart';

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

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Escribe tu correo';
    if (!_emailPattern.hasMatch(v)) return 'Escribe un correo válido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryLighter : AppColors.primary;
    final error = state.errorMessage;

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeSlide(
                        child: AuthHeader(
                          accent: accent,
                          icon: Icons.school_rounded,
                          overline: 'Panel del Estudiante',
                          title: 'Ingresa con tu correo',
                          subtitle:
                              'Te enviaremos un código de 6 dígitos. No necesitas contraseña.',
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
                              AppTextField(
                                label: 'Correo institucional',
                                hint: 'tu.correo@universidad.edu',
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailCtrl,
                                enabled: !state.submitting,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                prefixIcon: Icons.alternate_email_rounded,
                                validator: _validateEmail,
                              ),
                              if (error != null) ...[
                                const SizedBox(height: AppSpacing.l),
                                AuthErrorBanner(message: error),
                              ],
                              const SizedBox(height: AppSpacing.l),
                              const AuthInfoNote(
                                icon: Icons.mark_email_read_outlined,
                                text:
                                    'Si no ves el mensaje en unos minutos, revisa tu carpeta de spam.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      FadeSlide(
                        delay: const Duration(milliseconds: 220),
                        child: AppButton(
                          label: 'Enviar código',
                          icon: Icons.mark_email_unread_outlined,
                          isLoading: state.submitting,
                          onPressed: state.submitting ? null : _submit,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      FadeSlide(
                        delay: const Duration(milliseconds: 300),
                        child: TextButton(
                          onPressed: state.submitting
                              ? null
                              : () => context.go('/auth/jury/login'),
                          child: const Text(
                              '¿Eres jurado? Ingresa con contraseña'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
