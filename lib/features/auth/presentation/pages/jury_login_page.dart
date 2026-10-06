import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/role_landing.dart';
import '../../../settings/presentation/settings_copy.dart';
import '../state/auth_controller.dart';
import 'jury_login_view.dart';

/// Conserva el contrato de login y decide el segundo paso indicado por el API.
class JuryLoginPage extends ConsumerStatefulWidget {
  const JuryLoginPage({super.key});

  @override
  ConsumerState<JuryLoginPage> createState() => _JuryLoginPageState();
}

class _JuryLoginPageState extends ConsumerState<JuryLoginPage> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _wrongRole = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Escribe tu correo';
    if (!_emailPattern.hasMatch(email)) return 'Escribe un correo válido';
    return null;
  }

  Future<void> _submit() async {
    if (ref.read(authControllerProvider).submitting) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final ok = await ref
        .read(authControllerProvider.notifier)
        .login(email: _emailCtrl.text, password: _passwordCtrl.text);
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    switch (resolveJuryLoginOutcome(ok: ok, state: state)) {
      case JuryLoginOutcome.notJury:
        setState(() => _wrongRole = true);
        await ref.read(authControllerProvider.notifier).logout();
      case JuryLoginOutcome.granted:
        setState(() => _wrongRole = false);
        context.go(landingPathForRole(state.user?.role));
      case JuryLoginOutcome.needsEmailCode:
        context.go('/auth/email-verify');
      case JuryLoginOutcome.needsTotp:
        context.go('/auth/totp');
      case JuryLoginOutcome.failed:
        if (_wrongRole) setState(() => _wrongRole = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final text = SettingsCopy.of(context);
    final message = _wrongRole
        ? text.t(
            'Esta cuenta no tiene permiso para ingresar al portal del jurado.')
        : state.errorMessage == null
            ? null
            : text.error(state.errorMessage!);

    return JuryLoginView(
      formKey: _formKey,
      emailController: _emailCtrl,
      passwordController: _passwordCtrl,
      passwordFocus: _passwordFocus,
      obscurePassword: _obscurePassword,
      wrongRole: _wrongRole,
      message: message,
      submitting: state.submitting,
      validateEmail: _validateEmail,
      onSubmit: _submit,
      onTogglePassword: () => setState(
        () => _obscurePassword = !_obscurePassword,
      ),
      onBack: () => context.go('/splash'),
      onEmailLogin: () => context.go('/auth/email-request'),
      onForgotPassword: () => context.go('/auth/password/forgot'),
    );
  }
}
