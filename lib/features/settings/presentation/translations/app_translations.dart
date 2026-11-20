// translations/app_translations.dart

import 'account_translations.dart';
import 'auth_translations.dart';
import 'gap_translations.dart';
import 'panel_translations.dart';
import 'student_projects_translations.dart';

/// Traducciones de textos estáticos. Claves en español para conservar la UI
/// existente; datos de usuarios y del servidor nunca se consultan aquí.
const appTranslations = <String, String>{
  // Accesos por rol y panel docente.
  'Acceso docente': 'Teacher access',
  'Inicio': 'Home',
  'Explorar': 'Explore',
  'Mi evaluación': 'My evaluation',
  'ESTUDIANTES': 'STUDENTS',
  'Soy estudiante': "I'm a student",
  'Recibe un código en tu correo institucional para evaluar a tus docentes y opinar sobre los proyectos de la feria.':
      'Get a code in your institutional email to evaluate your teachers and review the fair projects.',
  'DOCENTES': 'TEACHERS',
  'Soy docente': "I'm a teacher",
  'Recibe un código en tu correo institucional para ver tu evaluación y, si te asignaron, tus ferias como jurado.':
      'Get a code in your institutional email to see your evaluation and, if assigned, your fairs as a judge.',
  'Ingresar como docente': 'Sign in as a teacher',
  'JURADO EXTERNO': 'EXTERNAL JUDGE',
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
  'Plataforma académica': 'Academic platform',
  'Avisos': 'Alerts',
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
  'Mis certificados': 'My certificates',
  'Consulta tus certificados de feria': 'See your fair certificates',
  'Conoce la propuesta del equipo': 'See the team proposal',
  'Presentación en video': 'Video presentation',
  'DECLARACIÓN REGISTRADA': 'DECLARATION RECORDED',
  'EVALUACIÓN DE PROYECTOS': 'PROJECT EVALUATION',
  'Cada proyecto se califica con los criterios de su rúbrica. Esta evaluación no es tu voto oficial.':
      'Each project is scored with its rubric criteria. This evaluation is not your official vote.',
  'Rúbricas finalizadas': 'Completed rubrics',
  'Enviar enlace de recuperación': 'Send recovery link',
  'Escribe el correo asociado a tu cuenta. Si está registrado, recibirás un enlace para crear una contraseña nueva.':
      'Enter the email linked to your account. If it is registered, you will receive a link to create a new password.',
  'Esta feria aún no tiene proyectos evaluables': 'This fair has no projects to evaluate yet',
  'FERIA ASIGNADA': 'ASSIGNED FAIR',
  'FLUJO DEL JURADO': 'JURY FLOW',
  'Feria asignada': 'Assigned fair',
  'Los estados reflejan lo que el sistema tiene registrado para ti.':
      'The statuses reflect what the system has recorded for you.',
  'No se pudo enviar la solicitud': 'The request could not be sent',
  'Pendientes': 'Pending',
  'Recupera tu contraseña': 'Recover your password',
  'Si el mensaje tarda, revisa tu carpeta de spam o correo no deseado.':
      'If the message takes a while, check your spam or junk folder.',
  'Solicitud recibida. Si el correo está registrado, revisa tu bandeja y abre el enlace de recuperación.':
      'Request received. If the email is registered, check your inbox and open the recovery link.',
  'Tu participación': 'Your participation',
  'Volver al acceso': 'Back to sign-in',
  'puntos': 'points',
  'Mi evaluación docente': 'My teaching evaluation',
  'Votación oficial': 'Official vote',
  'Explorar ferias': 'Explore fairs',
  'Panel docente': 'Teacher panel',
  'Procesando': 'Processing',
  'CERTIFICADOS': 'CERTIFICATES',
  'Aún no tienes certificados': 'You do not have certificates yet',
  'Cuando la feria termine y la institución emita los certificados, aparecerán aquí.':
      'When the fair ends and the institution issues the certificates, they will appear here.',
  'HISTORIAL': 'HISTORY',
  'Evolución por periodo': 'Progress by period',
  'ALUMNOS': 'STUDENTS',
  'Comentarios anónimos': 'Anonymous comments',
  'Tus alumnos no dejaron comentarios.': 'Your students did not leave comments.',
  'RESULTADOS EN CAMINO': 'RESULTS ON THE WAY',
  'La jornada de evaluación sigue abierta': 'The evaluation period is still open',
  'Tus resultados aparecen cuando termine, para que nadie vea resultados parciales mientras los alumnos evalúan.':
      'Your results appear when it ends, so nobody sees partial results while students are still evaluating.',
  'SIN RESPUESTAS': 'NO RESPONSES',
  'Aún no hay evaluaciones enviadas': 'No evaluations have been submitted yet',
  'Los resultados se muestran al cerrar la jornada y recibir al menos una evaluación.':
      'Results are shown when the period closes and at least one evaluation is received.',
  'No pudimos cargar la opinión de tus compañeros. Desliza para reintentar.':
      'We could not load your classmates’ feedback. Pull to retry.',
  'Aún nadie calificó tu proyecto.': 'Nobody has rated your project yet.',
  'Aún no hay comentarios de mejora.': 'There are no improvement comments yet.',
  '¡Gracias! Tu opinión quedó guardada.': 'Thanks! Your feedback was saved.',
  'Mira el podio de cada categoría': 'See the podium for each category',
  'Esta categoría no recibió votos del jurado.': 'This category received no jury votes.',
  'Reintentar estado de declaración': 'Retry declaration status',
  'Firmar declaración para evaluar': 'Sign the declaration to evaluate',
  'Ir a la votación oficial': 'Go to the official vote',
  '¿Olvidaste tu contraseña?': 'Forgot your password?',
  'Avance de tu evaluación': 'Your evaluation progress',
  'Avance de rúbricas': 'Rubric progress',
  'TU DESEMPEÑO DOCENTE': 'YOUR TEACHING PERFORMANCE',
  'FAVORITO DEL PÚBLICO': 'AUDIENCE FAVORITE',
  'PANEL DOCENTE': 'TEACHER PANEL',
  'Hola': 'Hello',
  'Revisa cómo te evaluaron tus alumnos, los proyectos que asesoras y, si te asignaron, tus ferias como jurado.':
      'Review how your students evaluated you, the projects you advise and, if you were assigned, your fairs as a judge.',
  'Proyectos que asesoro': 'Projects I advise',
  'Consultando tus resultados…': 'Checking your results…',
  'No pudimos cargar tus resultados. Desliza para reintentar.':
      'We could not load your results. Pull to retry.',
  'Se publica cuando termine la jornada de evaluación.':
      'It is published when the evaluation period ends.',
  'Aún no hay suficientes evaluaciones para mostrarlas.':
      'There are not enough evaluations to show them yet.',
  'Consultando tus proyectos…': 'Checking your projects…',
  'No pudimos consultar tus proyectos.': 'We could not check your projects.',
  'Aún no asesoras proyectos en ferias.':
      'You are not advising fair projects yet.',
  'Promedio general': 'Overall average',
  'Todos tus cursos y periodos': 'All your courses and periods',
  'evaluaciones': 'evaluations',
  'FOTOS': 'PHOTOS',
  'VIDEO': 'VIDEO',
  'EQUIPO': 'TEAM',
  'Evaluaste a todos tus docentes de este periodo. ¡Gracias!':
      'You evaluated every teacher for this period. Thank you!',
  'Tu próxima jornada empieza en': 'Your next period starts in',
  'Tu jornada de evaluación ya empezó: desliza para actualizar.':
      'Your evaluation period has started: pull to refresh.',
  'Tu sede aún no publica la próxima jornada de evaluación. Cuando la publique, verás aquí su fecha y la cuenta regresiva.':
      'Your site has not published the next evaluation period yet. When it does, you will see the date and the countdown here.',
  'La jornada cierra en': 'The period closes in',
  'La jornada está abierta: tienes 1 docente por evaluar.':
      'The period is open: you have 1 teacher to evaluate.',
  'Evaluar': 'Evaluate',
  'Curso': 'Course',
  'Criterios': 'Criteria',
  'Al enviarla ya no podrás cambiarla. La institución verá que participaste, pero no tus respuestas individuales.':
      'Once you submit it, you cannot change it. The institution will see that you took part, but not your individual answers.',
  'TUS AVISOS': 'YOUR NOTICES',
  'Ver': 'View',
  'Resultados oficiales': 'Official results',
  'Ver mis certificados': 'View my certificates',
  'Gana el proyecto más votado por el jurado de cada categoría; un empate lo decide el puntaje de la rúbrica. Los votos son secretos.':
      'The project with the most jury votes in each category wins; a tie is decided by the rubric score. Votes are secret.',
  'Tu proyecto': 'Your project',
  'El mejor calificado por los alumnos. No cambia el resultado del jurado.':
      'The highest rated by students. It does not change the jury result.',
  'Soy nuevo en CampusVote': "I'm new to CampusVote",
  'Crea tu contraseña': 'Create your password',
  'Mínimo 10 caracteres.': 'At least 10 characters.',
  'Repite la contraseña': 'Repeat the password',
  'Iniciar sesión': 'Sign in',
  'Aceptar invitación': 'Accept invitation',
  'Crear mi cuenta y aceptar': 'Create my account and accept',
  'Ya tengo cuenta: iniciar sesión': 'I already have an account: sign in',
  'Reintentar estados': 'Retry statuses',
  'No pudimos cargar el estado de las rúbricas. Puedes abrir los proyectos y reintentar aquí.':
      'We could not load the rubric status. You can open the projects and retry here.',
  'Detalle del proyecto': 'Project details',
  'No pudimos cargar tus proyectos asignados.':
      'We could not load your assigned projects.',
  'Tu rúbrica': 'Your rubric',
  'Consultando tu evaluación…': 'Checking your evaluation…',
  'No pudimos consultar tu evaluación.': 'We could not check your evaluation.',
  'Registrada': 'Recorded',
  'criterios': 'criteria',
  'Vista previa: estudia el proyecto. Podrás completar la rúbrica y votar cuando empiece la feria.':
      'Preview: study the project. You can complete the rubric and vote when the fair starts.',
  'Ver mi rúbrica registrada': 'View my recorded rubric',
  'Completar mi rúbrica': 'Complete my rubric',
  'Voto de tu categoría': 'Your category vote',
  'Consultando estado del voto…': 'Checking your vote status…',
  'No pudimos consultar tu voto.': 'We could not check your vote.',
  'Emitido': 'Cast',
  'El voto es anónimo. Aquí solo aparece si ya votaste en esta categoría.':
      'The vote is anonymous. This only shows whether you already voted in this category.',
  'Jornada abierta': 'Period open',
  'Jornada cerrada': 'Period closed',
  'Jornada próxima': 'Upcoming period',
  'Solo ves cuántos te evaluaron, nunca quién ni qué respondió.':
      'You only see how many evaluated you, never who or what they answered.',
  'HOY ERES JURADO': 'TODAY YOU ARE A JUDGE',
  'Entrar como jurado': 'Enter as a judge',
  'Jurado de ferias': 'Fair judge',
  'Consultando tus asignaciones…': 'Checking your assignments…',
  'Serás jurado': 'You will be a judge',
  'Historial de jurado': 'Judge history',
  'No tienes ferias asignadas. Si la organización te elige como jurado, aparecerán aquí.':
      'You have no assigned fairs. If the organization chooses you as a judge, they will appear here.',
  'Califica los proyectos de tus categorías y emite tu voto. No verás los proyectos que asesoras.':
      'Score the projects in your categories and cast your vote. You will not see the projects you advise.',
  'Los resultados aún no están': 'Results are not',
  'disponibles': 'available',
  'Estamos en proceso de evaluación de los proyectos. Los resultados se publicarán aquí una vez que el jurado haya finalizado su revisión.':
      'Projects are still being evaluated. Results will be published here once the jury finishes its review.',
  'próximamente': 'coming soon',
  'Evaluado': 'Evaluated',
  'Docente por confirmar': 'Teacher to be confirmed',
  'Para terminar': 'To finish',
  'Cuando se publique la jornada de evaluación de tus cursos del periodo, tus docentes aparecerán aquí.':
      'When the evaluation period for your courses is published, your teachers will appear here.',
  'SIGUIENTE ACCIÓN': 'NEXT ACTION',
  'Fuera de jornada': 'Outside the period',
  'Se evalúan solo el día publicado por tu sede.':
      'They are evaluated only on the day published by your site.',
  'SEGUIMIENTO': 'FOLLOW-UP',
  'ASESORÍA': 'ADVISING',
  'Aún no asesoras proyectos': 'You are not advising projects yet',
  'Cuando la sede te autorice como asesor de una feria e inscribas proyectos con tus alumnos, aparecerán aquí.':
      'When your site authorizes you as a fair adviser and you register projects with your students, they will appear here.',
  'RÚBRICA': 'RUBRIC',
  'Por criterio': 'By criterion',
  'De mayor a menor puntaje.': 'From highest to lowest score.',
  'CURSOS': 'COURSES',
  'Por curso': 'By course',
  'Solo cursos con suficientes evaluaciones.':
      'Only courses with enough evaluations.',
  'PUNTAJES': 'SCORES',
  'Cómo te calificaron': 'How they rated you',
  'Total de estrellas recibidas en los criterios.':
      'Total stars received on the criteria.',
  'Espera que el alumno confirme': 'Waiting for the student to confirm',
  'En revisión del comité': 'Under committee review',
  'Observado': 'Needs changes',
  'La evaluación aún no empieza': 'The evaluation has not started yet',
  'La jornada de evaluación terminó': 'The evaluation period has ended',
  'Ya no se reciben evaluaciones para este curso en el periodo.':
      'Evaluations are no longer accepted for this course in this period.',
  'Rúbrica no disponible': 'Rubric unavailable',
  'Tu sede aún no publicó los criterios para evaluar este curso. Vuelve a intentarlo más tarde.':
      'Your site has not published the criteria to evaluate this course yet. Try again later.',
  'calificados': 'rated',
  'de 5': 'out of 5',
  ...authTranslations,
  ...juryTranslations,
  ...teachingTranslations,
  ...studentProjectsTranslations,
  ...accountTranslations,
  ...gapTranslations,
};
