/// Roles de usuario tal como los devuelve el backend (`user.role`).
///
/// Se centralizan aquí para no repetir literales 'JURY' / 'STUDENT' por el
/// código: un typo en un string no lo detecta el compilador.
class AuthRole {
  const AuthRole._();

  static const String jury = 'JURY';
  static const String teacher = 'TEACHER';
  static const String student = 'STUDENT';
  static const String admin = 'ADMIN';
  static const String superAdmin = 'SUPERADMIN';

  /// Etiqueta legible para la pantalla de perfil.
  static String label(String? role) => switch (role) {
        jury => 'Jurado',
        teacher => 'Docente',
        student => 'Estudiante',
        admin => 'Administrador',
        superAdmin => 'Super administrador',
        _ => 'Miembro',
      };
}
