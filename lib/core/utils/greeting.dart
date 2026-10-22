/// Saludo según la hora del celular: «Buenos días», «Buenas tardes» o
/// «Buenas noches». No usa nada del usuario más allá de su nombre de pila.
String timeGreeting(DateTime now) => now.hour < 12
    ? 'Buenos días'
    : now.hour < 19
        ? 'Buenas tardes'
        : 'Buenas noches';

/// Primer nombre para saludar («Juan Carlos» → «Juan»); null si no hay.
String? firstNameOf(String? name) {
  final first = name?.trim().split(RegExp(r'\s+')).first;
  return first == null || first.isEmpty ? null : first;
}
