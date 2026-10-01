import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/campusvote_theme.dart';
import '../../../../core/routing/role_landing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_appbar.dart';
import '../../../../core/widgets/fade_slide.dart';
import '../state/auth_controller.dart';
import '../widgets/auth_form_widgets.dart';
import '../widgets/jury_login_widgets.dart';

/// Acceso del JURADO: correo + contraseña.
///
/// El jurado no tiene cuenta autogestionada: el administrador crea la cuenta y
/// le envía las credenciales por correo. Por eso este flujo pide contraseña
/// (a diferencia del estudiante, que pide un código de un solo uso).
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final ok = await ref
        .read(authControllerProvider.notifier)
        .login(email: _emailCtrl.text, password: _passwordCtrl.text);

    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    final outcome = resolveJuryLoginOutcome(ok: ok, state: state);

    switch (outcome) {
      // El backend es la autoridad del rol: si la cuenta no es de jurado se
      // cierra la sesión para no dejarla dentro de un panel ajeno.
      case JuryLoginOutcome.notJury:
        setState(() => _wrongRole = true);
        await ref.read(authControllerProvider.notifier).logout();
      case JuryLoginOutcome.granted:
        setState(() => _wrongRole = false);
        context.go(landingPathForRole(state.user?.role));
      // El tempToken del segundo factor ya quedó en el estado.
      case JuryLoginOutcome.needsEmailCode:
        context.go('/auth/email-verify');
      case JuryLoginOutcome.needsTotp:
        context.go('/auth/totp');
      // El mensaje de error ya está en el estado y se pinta inline.
      case JuryLoginOutcome.failed:
        if (_wrongRole) {
          setState(() => _wrongRole = false);
        }
    }
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
    final accent = isDark ? AppColors.accentLight : AppColors.accent;
    final message = _wrongRole
        ? 'Esa cuenta no pertenece al panel del jurado. Entra desde el panel de estudiante.'
        : state.errorMessage;

    return CampusVoteTheme(
      accent: AppColors.accent,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: buildAuthAppBar(context, onBack: () => context.go('/splash')),
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
                          icon: Icons.gavel_rounded,
                          overline: 'Acceso de evaluación',
                          title: 'Portal del jurado',
                          subtitle:
                              'Ingresa con las credenciales institucionales asignadas por el administrador.',
                          logoSize: 112,
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
                                label: 'Correo del jurado',
                                hint: 'jurado@universidad.edu',
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailCtrl,
                                enabled: !state.submitting,
                                textInputAction: TextInputAction.next,
                                prefixIcon: Icons.alternate_email_rounded,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: AppSpacing.l),
                              AppTextField(
                                label: 'Contraseña institucional',
                                hint: 'Escribe tu contraseña',
                                obscureText: _obscurePassword,
                                controller: _passwordCtrl,
                                focusNode: _passwordFocus,
                                enabled: !state.submitting,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                prefixIcon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Mostrar contraseña'
                                      : 'Ocultar contraseña',
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: AppDimensions.iconMedium,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                                validator: (value) => (value ?? '').isEmpty
                                    ? 'Escribe tu contraseña'
                                    : null,
                              ),
                              if (message != null) ...[
                                const SizedBox(height: AppSpacing.l),
                                AuthErrorBanner(
                                  message: message,
                                  title: _wrongRole
                                      ? 'Cuenta no autorizada'
                                      : 'No se pudo abrir el acceso',
                                  icon: _wrongRole
                                      ? Icons.gavel_outlined
                                      : Icons.lock_outline_rounded,
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
                          label: 'Entrar al panel de evaluación',
                          icon: Icons.login_rounded,
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
                              : () => context.go('/auth/email-request'),
                          child: const Text(
                              'Acceso para estudiante · recibir código'),
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
