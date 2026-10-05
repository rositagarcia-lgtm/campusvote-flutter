import 'translations_panels.dart';

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
  'Sobre mí': 'About me',
  'Configuración': 'Settings',
  'Seguridad': 'Security',
  'Contraseña': 'Password',
  'Correo': 'Email',
  'Rol': 'Role',
  'Nombre': 'Name',
  'Jurado': 'Jury',
  'Notificaciones': 'Notifications',
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

const authTranslations = <String, String>{
  'Escribe tu correo': 'Enter your email',
  'Escribe un correo válido': 'Enter a valid email',
  'Correo inválido': 'Invalid email',
  'Código incorrecto': 'Incorrect code',
  'Código expirado': 'Expired code',
  'Credenciales incorrectas': 'Incorrect credentials',
  'Completa todos los campos': 'Complete all fields',
  'Error al iniciar sesión': 'Sign-in error',
  'No se pudo cargar la información': 'Unable to load information',
  'Acceso estudiantil': 'Student access',
  'Identifica tu cuenta': 'Identify your account',
  'Usa tu correo institucional y recibe un código de acceso de un solo uso.':
      'Enter your institutional email to receive a one-time access code.',
  'Correo institucional del estudiante': 'Student institutional email',
  'No se pudo enviar el código': 'Could not send the code',
  'Si no ves el mensaje en unos minutos, revisa tu carpeta de spam.':
      'If you do not see the message in a few minutes, check your spam folder.',
  'Recibir código de acceso': 'Send access code',
  'Acceso para jurado · usar contraseña': 'Jury access · use password',
  'Ingresa un código de 6 dígitos': 'Enter a 6-digit code',
  'Te enviamos un nuevo código': 'We sent you a new code',
  'Espera un minuto y vuelve a intentar': 'Wait a minute and try again',
  'Verificación': 'Verification',
  'Verifica tu correo': 'Verify your email',
  'Ingresa el código de 6 dígitos que enviamos a tu correo.':
      'Enter the 6-digit code we sent to your email.',
  'Código de verificación': 'Verification code',
  'Si no lo recibes, revisa tu carpeta de spam o solicita uno nuevo.':
      'If you did not receive it, check your spam folder or request a new one.',
  'Verificar': 'Verify',
  'Reenviar código': 'Resend code',
  'Acceso de evaluación': 'Evaluation access',
  'Portal del jurado': 'Jury portal',
  'Ingresa con las credenciales institucionales asignadas por el administrador.':
      'Sign in with the institutional credentials provided by the administrator.',
  'Esa cuenta no pertenece al panel del jurado. Entra desde el panel de estudiante.':
      'This account does not belong to the jury panel. Use student access instead.',
  'Correo del jurado': 'Jury email',
  'Contraseña institucional': 'Institutional password',
  'Escribe tu contraseña': 'Enter your password',
  'Mostrar contraseña': 'Show password',
  'Ocultar contraseña': 'Hide password',
  'Cuenta no autorizada': 'Unauthorized account',
  'No se pudo abrir el acceso': 'Could not sign in',
  'Entrar al panel de evaluación': 'Sign in to the jury panel',
  'Acceso para estudiante · recibir código': 'Student access · receive code',
  'Revisa la información': 'Check your information',
  'Logo de CampusVote': 'CampusVote logo',
  'Tu contraseña': 'Your password',
  'Mantén tu contraseña fuerte. Se requieren 8+ caracteres con mayúscula, minúscula, número y símbolo.':
      'Keep your password strong. Use 8 or more characters, including upper- and lowercase letters, a number and a symbol.',
  'Cambiar contraseña': 'Change password',
  'Sesión activa': 'Active session',
  'Cerrar la sesión invalidará los tokens guardados en este dispositivo.':
      'Signing out will invalidate the tokens stored on this device.',
  'Verificación en dos pasos': 'Two-factor authentication',
  'Verificación en dos pasos (2FA)': 'Two-factor authentication (2FA)',
  'Activo': 'Enabled',
  'Inactivo': 'Disabled',
  '2FA está activo. Al iniciar sesión, además de tu contraseña deberás ingresar un código de 6 dígitos de tu aplicación autenticadora.':
      '2FA is enabled. When signing in, enter a 6-digit code from your authenticator app in addition to your password.',
  'Agrega una capa extra de seguridad. Al iniciar sesión, además de tu contraseña deberás ingresar un código de tu aplicación autenticadora.':
      'Add another layer of security. When signing in, enter a code from your authenticator app along with your password.',
  'Deshabilitar 2FA': 'Disable 2FA',
  'Configurar 2FA': 'Set up 2FA',
  '2FA deshabilitado': '2FA disabled',
  'Mi contraseña': 'My password',
  'Contraseña actualizada correctamente': 'Password updated successfully',
  'Requerido': 'Required',
  'Mínimo 8 caracteres': 'At least 8 characters',
  'Máximo 72 caracteres': 'Up to 72 characters',
  'Falta una minúscula': 'Add a lowercase letter',
  'Falta una mayúscula': 'Add an uppercase letter',
  'Falta un número': 'Add a number',
  'Falta un carácter especial': 'Add a special character',
  'Mostrar contraseñas': 'Show passwords',
  'Ocultar contraseñas': 'Hide passwords',
  'Tu contraseña es temporal. Cámbiala para continuar.':
      'Your password is temporary. Change it to continue.',
  'Contraseña actual': 'Current password',
  'Escribe tu contraseña actual': 'Enter your current password',
  'Nueva contraseña': 'New password',
  'Confirmar nueva contraseña': 'Confirm new password',
  'Las contraseñas no coinciden': 'Passwords do not match',
  'Usa una contraseña única que no compartas con otros servicios.':
      'Use a unique password that you do not share with other services.',
  'Cambiar y continuar': 'Change and continue',
  'Actualizar contraseña': 'Update password',
  'REQUISITOS': 'REQUIREMENTS',
  'Una minúscula': 'A lowercase letter',
  'Una mayúscula': 'An uppercase letter',
  'Un número': 'A number',
  'Un símbolo': 'A symbol',
  'cumplido': 'met',
  'pendiente': 'pending',
  'ESTADO DE ERROR': 'ERROR',
  'SIN RESULTADOS': 'NO RESULTS',
  'No pudimos cargar la información': 'Unable to load information',
  'Sin conexión a internet': 'No internet connection',
  'La solicitud tardó demasiado': 'The request took too long',
  'Sesión expirada. Inicia sesión nuevamente.':
      'Session expired. Please sign in again.',
  'No tienes permisos para realizar esta acción.':
      'You do not have permission to do this.',
  'El estado del recurso cambió. Intenta de nuevo.':
      'The item changed. Please try again.',
  'Ocurrió un error inesperado': 'An unexpected error occurred',
  'Token temporal no disponible': 'Temporary token unavailable',
  'Inicia de nuevo: el código expiró': 'Please start again: the code expired',
  'No se pudo reenviar el código': 'Could not resend the code',
  'El correo es obligatorio': 'Email is required',
  'La contraseña es obligatoria': 'Password is required',
  'El código TOTP debe tener 6 dígitos': 'The TOTP code must have 6 digits',
  'El código debe tener 6 dígitos': 'The code must have 6 digits',
  'La contraseña actual debe tener al menos 8 caracteres':
      'The current password must have at least 8 characters',
  'La contraseña es obligatoria para deshabilitar 2FA':
      'Password is required to disable 2FA',
  'No se encontró la imagen seleccionada': 'The selected image was not found',
  'No hay cambios para guardar': 'No changes to save',
  'Respuesta inesperada del servidor': 'Unexpected server response',
  'El servidor no habilitó el acceso por correo':
      'Email access is not enabled by the server',
  'Respuesta inesperada al refrescar token':
      'Unexpected response while refreshing the session',
  'Formato no soportado. Usa PNG, JPG o WEBP.':
      'Unsupported format. Use PNG, JPG or WEBP.',
  'El servidor no devolvió la URL de la imagen':
      'The server did not return an image URL',
  'No se pudo contactar al servidor. Revisa tu conexión o inténtalo más tarde.':
      'Could not reach the server. Check your connection or try again later.',
  'Certificado inválido': 'Invalid certificate',
  'Solicitud cancelada': 'Request cancelled',
  'Error desconocido de red': 'Unknown network error',
  'La calificación debe estar entre 1 y 5 estrellas':
      'Rating must be between 1 and 5 stars',
  'El comentario no puede superar los 2000 caracteres':
      'The comment cannot exceed 2,000 characters',
  'Ingresa tu código': 'Enter your code',
  'Ingresa el código de 6 dígitos de tu aplicación autenticadora.':
      'Enter the 6-digit code from your authenticator app.',
  'Usa el código vigente: tu aplicación lo renueva cada pocos segundos.':
      'Use the current code: your app refreshes it every few seconds.',
  'Ingresa los 6 dígitos': 'Enter all 6 digits',
  'Generando código QR...': 'Generating QR code...',
  'Escanea este QR con Google Authenticator, Microsoft Authenticator o similar.':
      'Scan this QR code with Google Authenticator, Microsoft Authenticator or a similar app.',
  'Código de la aplicación': 'App code',
  'Activar 2FA': 'Enable 2FA',
  'Después de activar, en cada login el sistema te pedirá el OTP además de tu contraseña.':
      'Once enabled, you will need an OTP as well as your password whenever you sign in.',
  'Códigos copiados': 'Codes copied',
  'Códigos de respaldo': 'Backup codes',
  'Guarda estos códigos en un lugar seguro. Los necesitarás si pierdes acceso a tu aplicación autenticadora.':
      'Keep these codes in a safe place. You will need them if you lose access to your authenticator app.',
  'Copiar todos': 'Copy all',
  'Guárdalos fuera de tu teléfono, por ejemplo impresos o en un gestor de contraseñas.':
      'Keep them outside your phone, such as on paper or in a password manager.',
  'He guardado mis códigos': 'I saved my codes',
  'Confirma con tu contraseña y el código actual para deshabilitar la verificación en dos pasos.':
      'Enter your password and current code to disable two-factor authentication.',
  'Código TOTP actual': 'Current TOTP code',
  'Tu cuenta será menos segura.': 'Your account will be less secure.',
  'Deshabilitar': 'Disable',
  'SECRETO (ENTRADA MANUAL)': 'SECRET (MANUAL ENTRY)',
  'Copiar': 'Copy',
  'Secreto copiado': 'Secret copied',
  'Código QR de configuración de la aplicación 2FA':
      'QR code to set up your 2FA app',
  'Código enviado a': 'Code sent to',
  'Verificar con código QR': 'Verify with a QR code',
  'Segunda opción: escanea el código sin abrir el correo':
      'Another option: scan the code without opening your email',
  'SEGUNDA OPCIÓN': 'ANOTHER OPTION',
  'Escanea el código con la aplicación institucional':
      'Scan the code with your institution’s app',
  'Si no tienes el correo a la vista, apunta con la cámara o con la app de la institución. El QR sirve para el mismo código de 6 dígitos.':
      'If your email is not available, scan with your camera or institution’s app. The QR code contains the same 6-digit code.',
  'Código QR de verificación de correo': 'Email verification QR code',
  'El QR caduca junto con el código enviado al correo.':
      'The QR code expires together with the code sent by email.',
  'Por seguridad, te pediremos un código enviado a tu correo antes de entrar.':
      'For security, we will ask for a code sent to your email before you sign in.',
  'Cargando introducción de CampusVote': 'Loading CampusVote introduction',
  'Omitir introducción': 'Skip introduction',
  'Código QR': 'QR code',
  'QR no disponible': 'QR code unavailable',
  'nombre.apellido@universidad.edu': 'first.last@university.edu',
  'jurado@universidad.edu': 'jury@university.edu',
};
