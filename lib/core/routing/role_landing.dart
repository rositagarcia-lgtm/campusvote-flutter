import '../../features/auth/domain/entities/auth_role.dart';

/// Pantalla de inicio de cada rol.
///
/// El jury entra con correo + contraseña (credencial que el administrador le
/// envía por correo) y aterriza en sus ferias; el resto de roles entra por
/// código de un solo uso y aterriza en la evaluación de docentes.
///
/// Nota: el destino se decide SIEMPRE con el rol que devuelve el backend
/// (`user.role`), nunca con el panel que el usuario tocó en el splash: el
/// cliente no es la autoridad sobre el rol.
String landingPathForRole(String? role) =>
    role == AuthRole.jury ? '/jury' : '/teaching';
