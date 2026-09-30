import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branding/campusvote_theme.dart';
import '../../../../core/routing/role_landing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/fade_slide.dart';
import '../state/auth_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const accent = AppColors.accent;
    final message = _wrongRole
        ? 'Esa cuenta no pertenece al panel del jurado. Entra desde el panel de estudiante.'
        : state.errorMessage;

    return CampusVoteTheme(
      accent: accent,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: theme.textTheme.bodyLarge?.color),
            tooltip: 'Volver',
            onPressed: () => context.go('/splash'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
              bottom: AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.l),
                  FadeSlide(
                    delay: Duration.zero,
                    offset: 30,
                    child: Center(
                      // Pre-login la identidad es la de CampusVote, no la del
                      // tenant: se usa el logo del proyecto de Flutter.
                      child: AppLogo.asset(size: 88),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeSlide(
                    delay: const Duration(milliseconds: 100),
                    offset: 20,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: AppRadii.rMedium,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.30),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.gavel_rounded,
                                size: 16, color: accent),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Panel del Jurado',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  FadeSlide(
                    delay: const Duration(milliseconds: 150),
                    offset: 20,
                    child: Text(
                      'Inicia sesión',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  FadeSlide(
                    delay: const Duration(milliseconds: 250),
                    offset: 20,
                    child: Text(
                      'Usa el correo y la contraseña que el administrador te envió. '
                      'Te pediremos un código de seguridad del correo antes de entrar.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.75),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FadeSlide(
                    delay: const Duration(milliseconds: 350),
                    offset: 20,
                    child: AppTextField(
                      label: 'Correo institucional',
                      hint: 'jurado@universidad.edu',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailCtrl,
                      enabled: !state.submitting,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.alternate_email_rounded,
                      validator: (value) {
                        final v = (value ?? '').trim();
                        if (v.isEmpty) {
                          return 'Escribe tu correo';
                        }
                        if (!_emailPattern.hasMatch(v)) {
                          return 'Escribe un correo válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  FadeSlide(
                    delay: const Duration(milliseconds: 420),
                    offset: 20,
                    child: AppTextField(
                      label: 'Contraseña',
                      hint: '••••••••',
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
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Escribe tu contraseña';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: AppSpacing.m),
                    FadeSlide(
                      delay: const Duration(milliseconds: 100),
                      offset: 10,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkDangerSoft
                              : AppColors.dangerSoft,
                          borderRadius: AppRadii.rMedium,
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.20),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.danger,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: Text(
                                message,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.danger,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  FadeSlide(
                    delay: const Duration(milliseconds: 500),
                    offset: 20,
                    child: AppButton(
                      label: 'Ingresar al panel',
                      icon: Icons.login_rounded,
                      isLoading: state.submitting,
                      onPressed: state.submitting ? null : _submit,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  FadeSlide(
                    delay: const Duration(milliseconds: 560),
                    offset: 20,
                    child: TextButton(
                      onPressed: state.submitting
                          ? null
                          : () => context.go('/auth/email-request'),
                      child: const Text('¿Eres estudiante? Pide un código'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
