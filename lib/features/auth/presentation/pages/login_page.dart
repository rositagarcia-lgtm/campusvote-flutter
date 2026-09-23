import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../state/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).login(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
    if (!mounted) return;
    if (ok) {
      // JURY → ferias asignadas; otros roles → electoral.
      final role = ref.read(authControllerProvider).user?.role;
      if (role == 'JURY') {
        context.go('/juries/fairs');
      } else {
        context.go('/voting');
      }
    } else {
      final temp = ref.read(authControllerProvider).tempToken;
      if (temp != null && mounted) {
        context.go('/auth/totp');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'CV',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  'CampusVote',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Sistema académico de votación',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppTextField(
                  label: 'Correo institucional',
                  hint: 'tu.correo@universidad.edu',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailCtrl,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: AppSpacing.l),
                AppTextField(
                  label: 'Contraseña',
                  obscureText: true,
                  controller: _passwordCtrl,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  prefixIcon: Icons.lock_outline_rounded,
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
                  label: 'Iniciar sesión',
                  icon: Icons.login_rounded,
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