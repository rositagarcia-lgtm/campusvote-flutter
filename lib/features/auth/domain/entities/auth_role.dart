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

  /// Roles que trabajan en el panel de jurado: el jurado externo (contraseña)
  /// y el docente asignado como jurado interno (código por correo). El
  /// backend ya autoriza a ambos en votación y rúbricas.
  static bool usesJuryPanel(String? role) => role == jury || role == teacher;

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
