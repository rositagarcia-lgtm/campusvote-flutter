import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../core/settings/app_preferences.dart';
import 'translations.dart';

/// Textos de Configuración; el mismo patrón puede extenderse a otras vistas.
class SettingsCopy {
  const SettingsCopy(this.language);

  final AppLanguage language;
  bool get isEnglish => language == AppLanguage.english;

  static SettingsCopy of(BuildContext context) => AppLanguageScope.of(context);

  /// Traduce texto de interfaz; los datos del servidor no pasan por aquí.
  String t(String spanish) =>
      isEnglish ? appTranslations[spanish] ?? spanish : spanish;

  /// Mensajes de error del dominio/API: no exponer excepciones técnicas ni
  /// mostrar en inglés texto de servidor que no está en el catálogo.
  String error(String message) {
    final lower = message.toLowerCase();
    if (RegExp(
      r'(estudiantes?\s+o\s+jura[dt]os?|students?\s+or\s+jur(?:y|ies))',
    ).hasMatch(lower)) {
      return t(
        'No encontramos una cuenta habilitada para este acceso. Verifica que uses el correo registrado en CampusVote.',
      );
    }
    final technical = RegExp(
      r'Exception|^Error \d+|StackTrace|Prisma|SQL|TypeError|undefined|Cannot read properties|/api/|HTTP\s?\d{3}',
      caseSensitive: false,
    ).hasMatch(message);
    if (technical ||
        (isEnglish &&
            !appTranslations.containsKey(message) &&
            !appTranslations.containsValue(message))) {
      return t('Ocurrió un error inesperado');
    }
    return t(message);
  }

  String get title => isEnglish ? 'Settings' : 'Configuración';
  String get back => isEnglish ? 'Back' : 'Volver';
  String get preferencesTitle =>
      isEnglish ? 'System preferences' : 'Preferencias del sistema';
  String get appearance => isEnglish ? 'APPEARANCE' : 'APARIENCIA';
  String get darkMode => isEnglish ? 'Dark mode' : 'Modo oscuro';
  String get darkModeHint => isEnglish
      ? 'Use a darker theme throughout the app'
      : 'Usa un tema oscuro en toda la aplicación';

  /// Contrapartida de [darkModeHint]: el interruptor apagado también necesita
  /// su descripción, o seguiría leyendo "tema oscuro" con el tema en claro.
  String get lightModeHint => isEnglish
      ? 'Use a lighter theme throughout the app'
      : 'Usa un tema claro en toda la aplicación';

  /// Se muestra mientras el usuario no ha elegido tema: sigue al sistema.
  String get darkModeSystemHint => isEnglish
      ? 'Following your device theme'
      : 'Sigue el tema de tu dispositivo';
  String get textSize => isEnglish ? 'Text size' : 'Tamaño de texto';
  String get textSizeHint => isEnglish
      ? 'Adjust the font size for easier reading'
      : 'Ajusta el tamaño de fuente para una mejor lectura';
  String get small => isEnglish ? 'Small' : 'Pequeño';
  String get normal => isEnglish ? 'Normal' : 'Normal';
  String get large => isEnglish ? 'Large' : 'Grande';
  String get languageSection => isEnglish ? 'LANGUAGE' : 'IDIOMA';
  String get languageLabel => isEnglish ? 'Language' : 'Idioma';
  String get languageHint => isEnglish
      ? 'Sets the language of menus and notices'
      : 'Define el idioma de los menús y los avisos';
  String get spanish => isEnglish ? 'Spanish' : 'Español';
  String get english => 'English';

  /// Etiqueta accesible del logo de la organización activa.
  String logoLabel(String organization) =>
      isEnglish ? 'Logo of $organization' : 'Logo de $organization';

  String openFairs(int count) => isEnglish
      ? '$count open fair${count == 1 ? '' : 's'}'
      : '$count feria${count == 1 ? '' : 's'} abierta${count == 1 ? '' : 's'}';

  String teachersToEvaluate(int count) => isEnglish
      ? '$count teacher${count == 1 ? '' : 's'} to evaluate'
      : '$count docente${count == 1 ? '' : 's'} por evaluar';

  String evaluatedProjects(int done, int total) => isEnglish
      ? 'You evaluated $done of $total projects'
      : 'Evaluaste $done de $total proyectos';

  String evaluationProgress(int done, int total, bool complete) => isEnglish
      ? '$done of $total projects evaluated${complete ? ' · completed' : ''}'
      : '$done de $total proyectos evaluados${complete ? ' · completado' : ''}';

  String checkedCriteria(int checked, int total) => isEnglish
      ? '$checked of $total criteria selected'
      : '$checked de $total criterios marcados';

  String votes(int count) => isEnglish
      ? '$count vote${count == 1 ? '' : 's'}'
      : '$count voto${count == 1 ? '' : 's'}';

  String formatDate(DateTime date) => DateFormat(
        isEnglish ? 'MM/dd/yyyy h:mm a' : 'dd/MM/yyyy HH:mm',
      ).format(date.toLocal());

  String recordedOn(DateTime date) => isEnglish
      ? 'Recorded on ${formatDate(date)}'
      : 'Registrada el ${formatDate(date)}';

  String publishedOn(DateTime? date, String? by) => isEnglish
      ? 'Published on ${date == null ? '' : formatDate(date)}${by == null ? '' : ' by $by'}'
      : 'Publicado el ${date == null ? '' : formatDate(date)}${by == null ? '' : ' por $by'}';

  String openingIn(Duration time) {
    final remaining = time.inDays > 0
        ? (isEnglish
            ? '${time.inDays} day${time.inDays == 1 ? '' : 's'}'
            : '${time.inDays} día${time.inDays == 1 ? '' : 's'}')
        : time.inHours > 0
            ? '${time.inHours} h ${time.inMinutes % 60} min'
            : '${time.inMinutes} min';
    return isEnglish
        ? 'Voting opens in $remaining'
        : 'La votación abre en $remaining';
  }

  String closingIn(String remaining) =>
      isEnglish ? 'Closes in $remaining' : 'Cierra en $remaining';

  String teacherRating(String teacher, String course) => isEnglish
      ? 'How would you rate $teacher in $course?'
      : '¿Cómo calificas el desempeño de $teacher en $course?';

  String term(int cycle) => isEnglish ? 'Term $cycle' : 'Ciclo $cycle';

  String receiptCode(String code) =>
      isEnglish ? 'Receipt code $code' : 'Código de comprobante $code';

  String rank(int? position, bool winner) => isEnglish
      ? 'Rank $position${winner ? ', winner' : ''}'
      : 'Puesto $position${winner ? ', ganador' : ''}';

  String selectedCriteria(int count, int total) =>
      isEnglish ? '$count of $total' : '$count de $total';

  String backupCodes(int count) =>
      isEnglish ? 'YOUR CODES · $count' : 'TUS CÓDIGOS · $count';

  String organizationIdentity(String name) =>
      isEnglish ? 'Identity of $name' : 'Identidad de $name';

  String notificationsTooltip(int unreadCount) => unreadCount == 0
      ? t('Notificaciones')
      : isEnglish
          ? 'Notifications: $unreadCount unread'
          : 'Notificaciones: $unreadCount sin leer';

  String pendingAssignments(int count) =>
      isEnglish ? '$count pending' : '$count pendiente${count == 1 ? '' : 's'}';

  String ratingOutOfFive(int score) =>
      isEnglish ? '$score out of 5' : '$score de 5';

  String ratingStars(int score) =>
      isEnglish ? '$score out of 5 stars' : '$score de 5 estrellas';

  String selectedRating(int score) => isEnglish
      ? 'You selected $score out of 5.'
      : 'Seleccionaste $score de 5.';

  String votedOn(DateTime date) => isEnglish
      ? 'Recorded on ${formatDate(date)}'
      : 'Registrado el ${formatDate(date)}';
}

class AppLanguageScope extends InheritedWidget {
  const AppLanguageScope(
      {super.key, required this.language, required super.child});

  final AppLanguage language;

  static SettingsCopy of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLanguageScope>();
    return SettingsCopy(scope?.language ?? AppLanguage.spanish);
  }

  @override
  bool updateShouldNotify(AppLanguageScope oldWidget) =>
      language != oldWidget.language;
}
