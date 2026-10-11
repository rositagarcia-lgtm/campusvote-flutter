import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_appbar.dart';
import '../../../../core/widgets/fade_slide.dart';
import '../../../settings/presentation/settings_copy.dart';
import '../widgets/auth_form_widgets.dart';
import '../widgets/jury_login_widgets.dart';

/// Vista del jurado; la autorización y las rutas siguen en [JuryLoginPage].
class JuryLoginView extends StatelessWidget {
  const JuryLoginView({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.wrongRole,
    required this.message,
    required this.submitting,
    required this.validateEmail,
    required this.onSubmit,
    required this.onTogglePassword,
    required this.onBack,
    required this.onEmailLogin,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocus;
  final bool obscurePassword;
  final bool wrongRole;
  final String? message;
  final bool submitting;
  final FormFieldValidator<String> validateEmail;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onBack;
  final VoidCallback onEmailLogin;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    const accent = AppColors.juryAccessInk;
    const buttonColor = AppColors.studentAccess;

    return Scaffold(
      appBar: buildAuthAppBar(
        context,
        onBack: onBack,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.l),
            child: Center(
              child: AuthAppBarBadge(
                accent: buttonColor,
                icon: PhosphorIconsRegular.shieldCheck,
                label: text.t('Acceso institucional'),
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
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlide(
                      child: AuthHeader(
                        accent: accent,
                        icon: PhosphorIconsFill.gavel,
                        overline: text.t('JURADO CALIFICADOR'),
                        title: text.t('Portal del jurado'),
                        subtitle: text.t(
                          'Ingresa con las credenciales que te entregó la organización para acceder a tu participación como jurado.',
                        ),
                        logoSize: 64,
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
                              label: text.t('Correo institucional'),
                              labelTrailing:
                                  const _RequiredLabel(accent: accent),
                              hint: 'nombre@institucion.edu',
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              controller: emailController,
                              enabled: !submitting,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => passwordFocus.requestFocus(),
                              prefixIcon: PhosphorIconsRegular.at,
                              validator: validateEmail,
                            ),
                            const SizedBox(height: AppSpacing.l),
                            AppTextField(
                              label: text.t('Contraseña institucional'),
                              labelTrailing:
                                  const _RequiredLabel(accent: accent),
                              hint: text.t('Escribe tu contraseña'),
                              obscureText: obscurePassword,
                              controller: passwordController,
                              focusNode: passwordFocus,
                              enabled: !submitting,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => onSubmit(),
                              prefixIcon: PhosphorIconsRegular.lockSimple,
                              suffix: IconButton(
                                tooltip: obscurePassword
                                    ? text.t('Mostrar contraseña')
                                    : text.t('Ocultar contraseña'),
                                icon: Icon(
                                  obscurePassword
                                      ? PhosphorIconsRegular.eye
                                      : PhosphorIconsRegular.eyeSlash,
                                  size: AppDimensions.iconMedium,
                                ),
                                onPressed: submitting ? null : onTogglePassword,
                              ),
                              validator: (value) => (value ?? '').isEmpty
                                  ? 'Escribe tu contraseña'
                                  : null,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: submitting ? null : onForgotPassword,
                                child: const Text('¿Olvidaste tu contraseña?'),
                              ),
                            ),
                            if (message != null) ...[
                              const SizedBox(height: AppSpacing.l),
                              AuthErrorBanner(
                                message: message!,
                                title: text.t(wrongRole
                                    ? 'Cuenta no autorizada'
                                    : 'No se pudo abrir el acceso'),
                                icon: wrongRole
                                    ? PhosphorIconsRegular.gavel
                                    : PhosphorIconsRegular.lockSimple,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.l),
                            const JurySecurityNote(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    FadeSlide(
                      delay: const Duration(milliseconds: 220),
                      child: AppButton(
                        label: text.t('Entrar al panel de evaluación'),
                        icon: PhosphorIconsRegular.arrowRight,
                        backgroundColor: buttonColor,
                        foregroundColor: AppColors.inkInverse,
                        isLoading: submitting,
                        onPressed: submitting ? null : onSubmit,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    FadeSlide(
                      delay: const Duration(milliseconds: 300),
                      child: TextButton(
                        onPressed: submitting ? null : onEmailLogin,
                        child: Text(
                          text.t('Acceso con código institucional'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: buttonColor),
                        ),
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

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) => Text(
        SettingsCopy.of(context).t('Requerido'),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
      );
}
