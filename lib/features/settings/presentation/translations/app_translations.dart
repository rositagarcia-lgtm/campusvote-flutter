// translations/app_translations.dart

import 'auth_translations.dart';
import 'panel_translations.dart';

/// Traducciones de textos estáticos. Claves en español para conservar la UI
/// existente; datos de usuarios y del servidor nunca se consultan aquí.
const appTranslations = <String, String>{
  'Volver': 'Back',
  'Actualizar': 'Refresh',
  'Cerrar sesión': 'Sign out',
  'Salir': 'Sign out',
  'Cancelar': 'Cancel',
  'Confirmar': 'Confirm',
  'Entendido': 'Got it',
  'Reintentar': 'Retry',
  'Cargando...': 'Loading...',
  'Mi panel': 'My panel',
  'Mi cuenta': 'My account',
  'Sobre mí': 'About me',
  'Configuración': 'Settings',
  'Seguridad': 'Security',
  'Contraseña': 'Password',
  'Correo': 'Email',
  'Rol': 'Role',
  'Nombre': 'Name',
  'Jurado': 'Jury',
  'Notificaciones': 'Notifications',
  'Consulta tus avisos recientes': 'Review your recent notifications',
  'Estudiante': 'Student',
  'Docente': 'Teacher',
  'Administrador': 'Administrator',
  'Super administrador': 'Super administrator',
  'Miembro': 'Member',
  'Usuario': 'User',
  'Institución': 'Institution',
  'Tu cuenta': 'Your account',
  'Cuenta': 'Account',
  'Sesión': 'Session',
  'Organización de tu cuenta': 'Your account organization',
  'Seguridad y contraseña': 'Security and password',
  'Gestiona tu acceso y protege tu cuenta':
      'Manage your access and protect your account',
  '¿Seguro que quieres salir de la aplicación?':
      'Are you sure you want to sign out?',
  '¿Estás seguro que deseas salir de CampusVote?':
      'Are you sure you want to sign out of CampusVote?',
  'Tomar foto': 'Take photo',
  'Elegir de la galería': 'Choose from gallery',
  'Cerrar': 'Close',
  'Cambiar foto de perfil': 'Change profile photo',
  'No se pudo abrir la cámara o galería':
      'Could not open the camera or gallery',
  'Foto de perfil actualizada': 'Profile photo updated',
  'No se pudo actualizar la foto': 'Could not update profile photo',
  'VOTACIÓN Y EVALUACIÓN ACADÉMICA': 'ACADEMIC VOTING AND EVALUATION',
  'Acceso': 'Access',
  'Acceso institucional': 'Institutional access',
  'Verificaci\u00f3n de acceso': 'Access verification',
  'ESTUDIANTES Y JURADOS INTERNOS': 'STUDENTS AND INTERNAL JURORS',
  'ACCESO DE JURADO': 'JURY ACCESS',
  'Acceso por correo': 'Email access',
  'Jurado calificador': 'Jury member',
  'Selecciona tu opción para continuar de forma segura.':
      'Choose your access option to continue securely.',
  'Estudiantes y docentes asignados como jurados reciben un c\u00f3digo en su correo institucional. Selecciona este acceso si esa es tu participaci\u00f3n.':
      'Students and teachers assigned as jurors receive a code at their institutional email. Choose this access if that is your role.',
  'Ingresa con las credenciales de jurado que te facilit\u00f3 la organizaci\u00f3n. Si no las tienes, consulta al comit\u00e9 organizador.':
      'Sign in with the jury credentials provided by your organization. If you do not have them, contact the organizing committee.',
  'Usa el correo y las credenciales asignadas a tu participaci\u00f3n.':
      'Use the email and credentials assigned to your participation.',
  'Elige cómo participar': 'Choose how to participate',
  'Selecciona tu perfil para continuar.': 'Select your profile to continue.',
  'Evalúa a tus docentes con un código enviado a tu correo. No necesitas contraseña.':
      'Evaluate your teachers using a code sent to your email. No password required.',
  'Continuar con mi correo': 'Continue with my email',
  'Califica proyectos e ingresa con las credenciales enviadas por el administrador.':
      'Evaluate projects and sign in with the credentials provided by the administrator.',
  'Ingresar como jurado': 'Sign in as jury',
  'Acceso exclusivo para la comunidad académica':
      'Exclusive access for the academic community',
  'Panel del jurado': 'Jury Panel',
  'Evalúa proyectos y vota en tus ferias asignadas':
      'Evaluate projects and vote in your assigned fairs',
  'Asignadas': 'Assigned',
  'Abiertas': 'Open',
  'Sin ferias abiertas': 'No open fairs',
  'Abiertas · evaluar y votar': 'Open · evaluate and vote',
  'Otras ferias': 'Other fairs',
  'No tienes ferias asignadas por ahora.':
      'You have no assigned fairs right now.',
  'Abierta': 'Open',
  'En preparación': 'In preparation',
  'Cerrada': 'Closed',
  'Sin estado': 'No status',
  'Ver proyectos de tu categoría': 'View projects in your category',
  'Votación y rúbrica': 'Voting and rubric',
  ...authTranslations,
  ...juryTranslations,
  ...teachingTranslations,
};
