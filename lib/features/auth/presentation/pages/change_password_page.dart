import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/role_landing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../state/auth_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: buildCampusVoteAppBar(
        context,
        title: widget.required ? 'Cambiar contraseña' : 'Mi contraseña',
        leading: widget.required ? const SizedBox.shrink() : null,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              if (widget.required) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: const BoxDecoration(
                    color: AppColors.warningSoft,
                    borderRadius: AppRadii.rMedium,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.priority_high_rounded,
                          color: AppColors.warning),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          'Tu contraseña es temporal. Cámbiala para continuar.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
              ],
              AppTextField(
                label: 'Contraseña actual',
                obscureText: true,
                controller: _currentCtrl,
                prefixIcon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: 'Nueva contraseña',
                obscureText: true,
                controller: _newCtrl,
                prefixIcon: Icons.lock_rounded,
                helperText:
                    'Mín. 8 caracteres: mayúscula, minúscula, número y símbolo.',
                validator: _passwordValidator,
              ),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: 'Confirmar nueva contraseña',
                obscureText: true,
                controller: _confirmCtrl,
                prefixIcon: Icons.lock_rounded,
                validator: (v) {
                  if (v != _newCtrl.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: widget.required
                    ? 'Cambiar y continuar'
                    : 'Actualizar contraseña',
                icon: Icons.check_rounded,
                isLoading: state.submitting,
                onPressed: state.submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
