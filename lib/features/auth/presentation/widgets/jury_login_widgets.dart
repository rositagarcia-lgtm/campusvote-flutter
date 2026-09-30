import 'package:flutter/material.dart';

import 'auth_form_widgets.dart';

/// Nota informativa sobre la verificación de seguridad en dos pasos del jurado.
///
/// El jurado no tiene cuenta autogestionada: el administrador crea la cuenta y
/// le envía las credenciales por correo. Antes de entrar, el sistema pide un
/// código enviado a ese mismo correo.
class JurySecurityNote extends StatelessWidget {
  const JurySecurityNote({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthInfoNote(
      icon: Icons.shield_outlined,
      text:
          'Por seguridad, te pediremos un código enviado a tu correo antes de entrar.',
    );
  }
}
