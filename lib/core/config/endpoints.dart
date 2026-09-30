/// Endpoints REST del backend CampusVote.
///
/// Mantener centralizado para evitar URLs dispersas.
class ApiEndpoints {
  const ApiEndpoints._();

  // Auth
  static const String login = '/api/auth/login';
  static const String loginTotp = '/api/auth/totp/login-verify';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';
  static const String loginEmailRequest = '/api/auth/email/request';
  static const String loginEmailVerify = '/api/auth/email/login-verify';
  static const String loginEmailResend = '/api/auth/email/resend';
  static const String totpStatus = '/api/auth/2fa/status';
  static const String totpSetup = '/api/auth/totp/setup';
  static const String totpVerify = '/api/auth/totp/verify';
  static const String totpDisable = '/api/auth/totp/disable';
  static const String changeMyPassword = '/api/users/me/password';
  static const String updateMe = '/api/users/me';
  static const String uploadAvatar = '/api/upload/avatar';

  // Organization (branding)
  static String organizationById(String id) => '/api/organizations/$id';

  // Teaching evaluation — STUDENT (evaluación docente)
  static const String myTeachingAssignments =
      '/api/academic/my-teaching-assignments';
  static const String evaluateTeacher = '/api/academic/teacher-evaluations';

  // Fair voting — JURY
  static const String myJuryAssignments = '/api/fairs/my-assignments';
  static String myJuryAssignmentDetail(String fairId) =>
      '/api/fairs/my-assignments/$fairId';

  // Proyectos APROBADOS de la feria que el JURY puede evaluar: el backend los
  // filtra por las categorías asignadas al jurado.
  static String fairProjects(String fairId) => '/api/fairs/$fairId/projects';

  // Projects (lectura autenticada, para listar proyectos votables)
  static const String projects = '/api/projects';
  static String projectById(String id) => '/api/projects/$id';

  // Fair rubric (checklist) — JURY
  static String fairRubric(String fairId) => '/api/fairs/$fairId/rubric';
  static String fairProjectRubric(String fairId, String projectId) =>
      '/api/fairs/$fairId/projects/$projectId/rubric';

  // Fair voting (anónimo, 1 voto por jurado)
  static String fairVotingStatus(String fairId) =>
      '/api/fairs/$fairId/voting/status';
  static String fairVotingCast(String fairId) => '/api/fairs/$fairId/votes';
}