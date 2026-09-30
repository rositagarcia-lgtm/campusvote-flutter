import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/role_landing.dart';
import '../../../../core/theme/app_colors.dart';
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
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Requerido';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (value.length > 72) return 'Máximo 72 caracteres';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Falta una minúscula';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Falta una mayúscula';
    if (!RegExp(r'\d').hasMatch(value)) return 'Falta un número';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return 'Falta un carácter especial';
    }
    return null;
  }

  Widget _visibilityToggle() => IconButton(
        tooltip: _obscure ? 'Mostrar contraseñas' : 'Ocultar contraseñas',
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: AppDimensions.iconMedium,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryLighter : AppColors.primary;

    return PopScope(
      // En el cambio obligatorio no se puede salir sin actualizar la clave.
      canPop: !widget.required,
      child: Scaffold(
        appBar: buildCampusVoteAppBar(
          context,
          title: widget.required ? 'Cambiar contraseña' : 'Mi contraseña',
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
                        const FadeSlide(
                          child: NoticeBanner(
                            tone: AppTone.warning,
                            liveRegion: true,
                            message:
                                'Tu contraseña es temporal. Cámbiala para continuar.',
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
                                label: 'Contraseña actual',
                                obscureText: _obscure,
                                controller: _currentCtrl,
                                enabled: !state.submitting,
                                textInputAction: TextInputAction.next,
                                prefixIcon: Icons.lock_outline_rounded,
                                suffix: _visibilityToggle(),
                                validator: (v) => (v ?? '').isEmpty
                                    ? 'Escribe tu contraseña actual'
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              AppTextField(
                                label: 'Nueva contraseña',
                                obscureText: _obscure,
                                controller: _newCtrl,
                                enabled: !state.submitting,
                                textInputAction: TextInputAction.next,
                                prefixIcon: Icons.lock_rounded,
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
                                label: 'Confirmar nueva contraseña',
                                obscureText: _obscure,
                                controller: _confirmCtrl,
                                enabled: !state.submitting,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                prefixIcon: Icons.lock_rounded,
                                validator: (v) => v != _newCtrl.text
                                    ? 'Las contraseñas no coinciden'
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.l),
                              const AuthInfoNote(
                                icon: Icons.shield_outlined,
                                text:
                                    'Usa una contraseña única que no compartas con otros servicios.',
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
                              ? 'Cambiar y continuar'
                              : 'Actualizar contraseña',
                          icon: Icons.check_rounded,
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
