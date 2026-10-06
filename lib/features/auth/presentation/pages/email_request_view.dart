import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_appbar.dart';
import '../../../../core/widgets/fade_slide.dart';
import '../../../settings/presentation/settings_copy.dart';
import '../widgets/auth_form_widgets.dart';

/// Presentación del acceso por correo para estudiantes y jurados internos.
class EmailRequestView extends StatelessWidget {
  const EmailRequestView({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.validateEmail,
    required this.submitting,
    required this.errorMessage,
    required this.onSubmit,
    required this.onBack,
    required this.onJuryLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final FormFieldValidator<String> validateEmail;
  final bool submitting;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final VoidCallback onJuryLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = SettingsCopy.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    const accent = AppColors.studentAccess;
    final error = errorMessage == null ? null : text.error(errorMessage!);

    return Scaffold(
      appBar: buildAuthAppBar(
        context,
        onBack: onBack,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.l),
            child: Center(
              child: AuthAppBarBadge(
                accent: accent,
                label: text.t('Paso 1 de 2 · Correo'),
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
                        icon: Icons.school_rounded,
                        overline: text.t('Acceso con código'),
                        title: text.t('Identifica tu cuenta'),
                        subtitle: text.t(
                          'Usa el correo institucional registrado. Si tu cuenta está habilitada, recibirás un código de un solo uso para confirmar el acceso.',
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
                              labelTrailing: Text(
                                text.t('Requerido'),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              hint: 'nombre.apellido@institucion.edu',
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              controller: emailController,
                              enabled: !submitting,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => onSubmit(),
                              prefixIcon: Icons.alternate_email_rounded,
                              validator: validateEmail,
                            ),
                            if (error != null) ...[
                              const SizedBox(height: AppSpacing.l),
                              AuthErrorBanner(
                                message: error,
                                title: text.t('No pudimos validar este acceso'),
                                icon: Icons.mark_email_unread_outlined,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.l),
                            NoticeBanner(
                              tone: AppTone.warning,
                              icon: Icons.mark_email_unread_outlined,
                              message: text.t(
                                'Si el mensaje tarda, revisa tu carpeta de spam o correo no deseado.',
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
                        label: text.t('Recibir código de acceso'),
                        icon: Icons.mail_outline_rounded,
                        backgroundColor: accent,
                        foregroundColor: AppColors.inkInverse,
                        isLoading: submitting,
                        onPressed: submitting ? null : onSubmit,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    FadeSlide(
                      delay: const Duration(milliseconds: 300),
                      child: TextButton(
                        onPressed: submitting ? null : onJuryLogin,
                        child: Text(
                          text.t('Acceso para jurado · usar contraseña'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeSlide(
                      delay: const Duration(milliseconds: 400),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            accent.withValues(alpha: 0.06),
                            theme.colorScheme.surface,
                          ),
                          borderRadius: AppRadii.rLarge,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: AppDimensions.iconMedium,
                              color: accent,
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: Text(
                                text.t(
                                  'El código es personal y de un solo uso. No lo compartas.',
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: muted,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
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
