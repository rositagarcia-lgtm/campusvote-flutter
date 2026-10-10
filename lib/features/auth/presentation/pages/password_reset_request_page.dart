import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_appbar.dart';
import '../state/auth_providers.dart';
import '../widgets/auth_form_widgets.dart';
import '../../../settings/presentation/settings_copy.dart';

/// Recuperación pública: el enlace se abre en el frontend institucional.
class PasswordResetRequestPage extends ConsumerStatefulWidget {
  const PasswordResetRequestPage({super.key});

  @override
  ConsumerState<PasswordResetRequestPage> createState() =>
      _PasswordResetRequestPageState();
}

class _PasswordResetRequestPageState
    extends ConsumerState<PasswordResetRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _submitting = false;
  bool _requested = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final clean = (value ?? '').trim();
    if (clean.isEmpty) return 'Escribe tu correo';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(clean)) {
      return 'Escribe un correo válido';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_submitting || _requested || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await ref.read(requestPasswordResetUseCaseProvider)(
      email: _email.text,
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _requested = result.isSuccess;
      _error = result.failureOrNull?.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = SettingsCopy.of(context);
    const accent = AppColors.studentAccess;
    return Scaffold(
      appBar: buildAuthAppBar(
        context,
        onBack: () => context.go('/auth/jury/login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  AuthHeader(
                    accent: accent,
                    icon: PhosphorIconsRegular.password,
                    overline: text.t('Acceso institucional'),
                    title: text.t('Recupera tu contraseña'),
                    subtitle: text.t(
                      'Escribe el correo asociado a tu cuenta. Si está registrado, recibirás un enlace para crear una contraseña nueva.',
                    ),
                    logoSize: 64,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_requested) ...[
                    NoticeBanner(
                      tone: AppTone.success,
                      icon: PhosphorIconsRegular.envelopeSimpleOpen,
                      liveRegion: true,
                      message: text.t(
                        'Solicitud recibida. Si el correo está registrado, revisa tu bandeja y abre el enlace de recuperación.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    AppButton(
                      label: text.t('Volver al acceso'),
                      icon: PhosphorIconsRegular.arrowLeft,
                      onPressed: () => context.go('/auth/jury/login'),
                    ),
                  ] else ...[
                    Form(
                      key: _formKey,
                      child: AuthFormCard(
                        accent: accent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              label: text.t('Correo institucional'),
                              hint: 'nombre@institucion.edu',
                              controller: _email,
                              enabled: !_submitting,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              prefixIcon: PhosphorIconsRegular.at,
                              validator: _validateEmail,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: AppSpacing.l),
                              AuthErrorBanner(
                                message: text.error(_error!),
                                title: text.t('No se pudo enviar la solicitud'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    AppButton(
                      label: text.t('Enviar enlace de recuperación'),
                      icon: PhosphorIconsRegular.envelopeSimple,
                      backgroundColor: accent,
                      foregroundColor: AppColors.inkInverse,
                      isLoading: _submitting,
                      onPressed: _submitting ? null : _submit,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
