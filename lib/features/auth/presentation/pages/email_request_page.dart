import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';
import 'email_request_view.dart';

/// Solicita el código de acceso usando el contrato actual de autenticación.
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
        .requestEmailLogin(email: _emailCtrl.text);
    if (!mounted) return;
    if (ok) context.go('/auth/email-verify');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return EmailRequestView(
      formKey: _formKey,
      emailController: _emailCtrl,
      validateEmail: _validateEmail,
      submitting: state.submitting,
      errorMessage: state.errorMessage,
      onSubmit: _submit,
      onBack: () => context.go('/splash'),
      onJuryLogin: () => context.go('/auth/jury/login'),
    );
  }
}
