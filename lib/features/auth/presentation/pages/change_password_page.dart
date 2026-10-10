import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/routing/role_landing.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/fade_slide.dart';
import '../state/auth_controller.dart';
import '../widgets/auth_form_widgets.dart';
import '../widgets/change_password_widgets.dart';
import '../../../settings/presentation/settings_copy.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  /// Si es `true`, el cambio es OBLIGATORIO (primer login / mustChangePassword).
  final bool required;
  const ChangePasswordPage({super.key, this.required = false});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).changePassword(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(SettingsCopy.of(context)
                .t('Contraseña actualizada correctamente'))),
      );
      if (widget.required) {
        // El 2FA no lo exige el backend para jurado/estudiante (tras el acceso
        // por correo `two_factor_enabled` ya queda activo), así que el cambio
        // obligatorio devuelve a su panel en vez de forzar el setup de TOTP.
        context.go(
            landingPathForRole(ref.read(authControllerProvider).user?.role));
      } else if (context.canPop()) {
        context.pop();
      }
    } else {
      final msg = ref.read(authControllerProvider).errorMessage;
      if (msg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(SettingsCopy.of(context).error(msg))));
      }
    }
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return SettingsCopy.of(context).t('Requerido');
    }
    if (value.length < 8) {
      return SettingsCopy.of(context).t('Mínimo 8 caracteres');
    }
    if (value.length > 72) {
      return SettingsCopy.of(context).t('Máximo 72 caracteres');
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return SettingsCopy.of(context).t('Falta una minúscula');
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return SettingsCopy.of(context).t('Falta una mayúscula');
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return SettingsCopy.of(context).t('Falta un número');
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return SettingsCopy.of(context).t('Falta un carácter especial');
    }
    return null;
  }

  Widget _visibilityToggle() => IconButton(
        tooltip: SettingsCopy.of(context)
            .t(_obscure ? 'Mostrar contraseñas' : 'Ocultar contraseñas'),
        icon: Icon(
          _obscure ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
          size: AppDimensions.iconMedium,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    // Ya hay sesión: el cambio de clave se pinta con la marca institucional.
    final accent = context.brandPrimary;
    final text = SettingsCopy.of(context);

    return PopScope(
      // En el cambio obligatorio no se puede salir sin actualizar la clave.
      canPop: !widget.required,
      child: Scaffold(
        appBar: buildCampusVoteAppBar(
          context,
          title: widget.required
              ? text.t('Cambiar contraseña')
              : text.t('Mi contraseña'),
          leading: widget.required ? const SizedBox.shrink() : null,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
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
                      if (widget.required) ...[
                        FadeSlide(
                          child: NoticeBanner(
                            tone: AppTone.warning,
                            liveRegion: true,
                            message: text.t(
                                'Tu contraseña es temporal. Cámbiala para continuar.'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.l),
                      ],
                      FadeSlide(
                        delay: const Duration(milliseconds: 100),
                        child: AuthFormCard(
                          accent: accent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                label: text.t('Contraseña actual'),
                                obscureText: _obscure,
                                controller: _currentCtrl,
                                enabled: !state.submitting,
                                textInputAction: TextInputAction.next,
                                prefixIcon: PhosphorIconsRegular.lockSimple,
                                suffix: _visibilityToggle(),
                                validator: (v) => (v ?? '').isEmpty
                                    ? text.t('Escribe tu contraseña actual')
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              AppTextField(
                                label: text.t('Nueva contraseña'),
                                obscureText: _obscure,
                                controller: _newCtrl,
                                enabled: !state.submitting,
                                textInputAction: TextInputAction.next,
                                prefixIcon: PhosphorIconsFill.lockSimple,
                                validator: _passwordValidator,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _newCtrl,
                                builder: (_, value, __) => PasswordRequirements(
                                  password: value.text,
                                  accent: accent,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.l),
                              AppTextField(
                                label: text.t('Confirmar nueva contraseña'),
                                obscureText: _obscure,
                                controller: _confirmCtrl,
                                enabled: !state.submitting,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                prefixIcon: PhosphorIconsFill.lockSimple,
                                validator: (v) => v != _newCtrl.text
                                    ? text.t('Las contraseñas no coinciden')
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.l),
                              AuthInfoNote(
                                icon: PhosphorIconsRegular.shield,
                                text: text.t(
                                    'Usa una contraseña única que no compartas con otros servicios.'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      FadeSlide(
                        delay: const Duration(milliseconds: 200),
                        child: AppButton(
                          label: widget.required
                              ? text.t('Cambiar y continuar')
                              : text.t('Actualizar contraseña'),
                          icon: PhosphorIconsBold.check,
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
        ),
      ),
    );
  }
}
