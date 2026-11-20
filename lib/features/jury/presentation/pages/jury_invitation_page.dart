import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/routing/deep_links.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_appbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../settings/presentation/settings_copy.dart';
import '../providers/jury_providers.dart';

const _acceptNew = '/api/fair-jury-invitations/accept/new';
const _acceptExisting = '/api/fair-jury-invitations/accept';

/// La invitación nunca debe caer en el error genérico de las pantallas de
/// datos: cada fallo tiene una acción concreta para quien abrió el enlace.
String describeInvitationError(Object error) {
  final failure = mapExceptionToFailure(error);
  final code = (failure.code ?? '').toUpperCase();

  if (failure is NetworkFailure || failure is TimeoutFailure) {
    return 'No pudimos contactar al servidor. Revisa tu conexión e inténtalo de nuevo.';
  }
  if (failure is UnauthorizedFailure || failure is ForbiddenFailure) {
    return 'Inicia sesión con el correo invitado para aceptar esta invitación.';
  }
  if (failure is ConflictFailure ||
      code.contains('ALREADY') ||
      code.contains('USED')) {
    return 'Esta invitación ya fue aceptada. Ingresa con tu cuenta de jurado.';
  }
  if (failure is ValidationFailure ||
      failure is NotFoundFailure ||
      code.contains('INVALID') ||
      code.contains('EXPIRED')) {
    return 'El enlace de la invitación no es válido o ya venció. Pide una nueva invitación.';
  }
  if (failure is ServerFailure || failure is RateLimitFailure) {
    return 'El servicio no está disponible por el momento. Inténtalo más tarde.';
  }
  return 'No pudimos procesar la invitación. Inténtalo de nuevo.';
}

/// `/j/invitacion?token=…` — el jurado externo acepta su invitación en la app.
///
/// * Con sesión: acepta con un toque y pasa a sus ferias.
/// * Sin cuenta: crea su contraseña (mín. 10) y luego inicia sesión.
/// * Con cuenta pero sin sesión: inicia sesión y vuelve aquí para aceptar.
class JuryInvitationPage extends ConsumerStatefulWidget {
  const JuryInvitationPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<JuryInvitationPage> createState() => _JuryInvitationPageState();
}

class _JuryInvitationPageState extends ConsumerState<JuryInvitationPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _done;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _post(
    String path,
    Map<String, dynamic> body, {
    bool public = false,
  }) async {
    final api = ref.read(apiClientProvider);
    final response = public
        ? await api.postPublic(path, body: body)
        : await api.post(path, body: body);
    if ((response.statusCode ?? 500) >= 400) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        setState(() => _error = describeInvitationError(error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _acceptWithSession() => _run(() async {
        await _post(_acceptExisting, {'token': widget.token});
        // El backend puede haber cambiado el rol al aceptar: actualizar el
        // perfil y limpiar el dashboard evita caer en "No pudimos cargar" al
        // entrar al panel con datos/rol anteriores a la invitación.
        await ref.read(authControllerProvider.notifier).refreshProfile();
        ref.invalidate(juryDashboardProvider);
        if (mounted) context.go('/jury');
      });

  Future<void> _createAccount() async {
    final problem = _password.text.length < 10
        ? 'La contraseña debe tener al menos 10 caracteres.'
        : _password.text != _confirm.text
            ? 'Las contraseñas no coinciden.'
            : null;
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    await _run(() async {
      await _post(
        _acceptNew,
        {'token': widget.token, 'password': _password.text},
        public: true,
      );
      if (mounted) {
        setState(() => _done =
            'Listo: tu cuenta de jurado quedó creada. Ingresa con tu correo y la contraseña que acabas de elegir.');
      }
    });
  }

  void _loginThenAccept() {
    // Tras iniciar sesión, el router vuelve a esta invitación para aceptarla.
    PendingDeepLink.remember('/j/invitacion?token=${widget.token}');
    context.go('/auth/jury/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authenticated =
        ref.watch(authControllerProvider.select((s) => s.authenticated));
    final validToken = widget.token.length >= 32;

    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Invitación de jurado'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(PhosphorIconsFill.gavel,
                        size: 44, color: theme.colorScheme.primary),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      SettingsCopy.of(context).t('Te invitaron a ser jurado'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      SettingsCopy.of(context).t(
                        'Acepta la invitación para ver la feria, firmar tu declaración y calificar los proyectos asignados.',
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (!validToken)
                      const NoticeBanner(
                        tone: AppTone.danger,
                        message:
                            'El enlace de la invitación está incompleto. Ábrelo de nuevo desde el correo.',
                      )
                    else if (_done != null) ...[
                      NoticeBanner(
                          tone: AppTone.success,
                          message: _done!,
                          liveRegion: true),
                      const SizedBox(height: AppSpacing.l),
                      AppButton(
                        label: 'Iniciar sesión',
                        icon: PhosphorIconsRegular.signIn,
                        onPressed: () => context.go('/auth/jury/login'),
                      ),
                    ] else if (authenticated)
                      AppButton(
                        label: 'Aceptar invitación',
                        icon: PhosphorIconsRegular.check,
                        isLoading: _busy,
                        onPressed: _busy ? null : _acceptWithSession,
                      )
                    else ...[
                      Text(SettingsCopy.of(context).t('Soy nuevo en CampusVote'),
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: AppSpacing.s),
                      AppTextField(
                        label: 'Crea tu contraseña',
                        helperText: 'Mínimo 10 caracteres.',
                        controller: _password,
                        obscureText: true,
                        enabled: !_busy,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: 'Repite la contraseña',
                        controller: _confirm,
                        obscureText: true,
                        enabled: !_busy,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppButton(
                        label: 'Crear mi cuenta y aceptar',
                        icon: PhosphorIconsRegular.check,
                        isLoading: _busy,
                        onPressed: _busy ? null : _createAccount,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      AppButton.outlined(
                        label: 'Ya tengo cuenta: iniciar sesión',
                        icon: PhosphorIconsRegular.signIn,
                        onPressed: _busy ? null : _loginThenAccept,
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.l),
                      NoticeBanner(
                          tone: AppTone.danger,
                          message: _error!,
                          liveRegion: true),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
