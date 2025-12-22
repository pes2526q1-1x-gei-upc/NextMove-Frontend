// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get register => 'Registrarse';

  @override
  String get emailAddress => 'Dirección de correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String welcomeTo(String appName) {
    return '¡Bienvenido a $appName!';
  }

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get useEmail => 'Utilizar el correo electrónico';

  @override
  String get whatIsYourEmailAddress =>
      '¿Cuál es tu dirección de correo electrónico?';

  @override
  String get continue_ => 'Continuar';

  @override
  String get needsToRegister =>
      'No hemos encontrado un usuario con ese correo electrónico. Ahora necesitarás registrarte con una nueva contraseña.';

  @override
  String get invalidEmail =>
      'El formato de la dirección de correo electrónico es inválido.';

  @override
  String get passwordRequirements =>
      'La contraseña debe tener al menos 8 caracteres con 1 minúscula, 1 mayúscula, 1 número y 1 carácter especial.';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get passwordNeedsLowercase =>
      'La contraseña debe tener al menos 1 letra minúscula.';

  @override
  String get passwordNeedsUppercase =>
      'La contraseña debe tener al menos 1 letra mayúscula.';

  @override
  String get passwordNeedsNumber =>
      'La contraseña debe tener al menos 1 número.';

  @override
  String get passwordNeedsSpecialCharacter =>
      'La contraseña debe tener al menos 1 carácter especial.';

  @override
  String get wrongPassword =>
      'La contraseña es incorrecta. Si usaste esta dirección de correo electrónico para registrarte con Google, inicia sesión con Google.';

  @override
  String get userDataPreferences => 'Completa tu perfil';

  @override
  String get nickname => 'Apodo';

  @override
  String get nicknameHint => 'Introduce tu apodo';

  @override
  String get birthdate => 'Fecha de nacimiento';

  @override
  String get bithdateHint => 'Ej: 1990-01-01';

  @override
  String get mandatoryBirthDate => 'La fecha de nacimiento es obligatoria';

  @override
  String get invalidBirthDateFormat =>
      'Formato de fecha inválido. Usa YYYY-MM-DD';

  @override
  String get telephoneNumber => 'Número de teléfono';

  @override
  String get preferredLanguage => 'Idioma preferido';

  @override
  String get userDescription => 'Descripción';

  @override
  String get userDescriptionHint => 'Introduce una breve descripción sobre ti';

  @override
  String get preferredMode => 'Modo preferido';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get imagePickerError =>
      'Se produjo un error al seleccionar la imagen.';

  @override
  String get saveChangesFeedback => 'Cambios guardados con éxito.';

  @override
  String get formError => 'Por favor, corrige los errores antes de guardar.';

  @override
  String get mandatoryNickname => 'El apodo es obligatorio';

  @override
  String get mandatoryPhoneNumber => 'El número de teléfono es obligatorio';

  @override
  String get invalidPhoneNumber => 'Formato de número de teléfono inválido';

  @override
  String get mandatoryPreferredMode => 'El modo preferido es obligatorio';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get nicknameNonEditable => 'Apodo';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get mandatoryFullName => 'El nombre completo es obligatorio';

  @override
  String errorOccurred(String error) {
    return 'Ha ocurrido un error: $error';
  }

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get searchStation => 'Busca una estación...';

  @override
  String get address => 'Dirección';

  @override
  String get totalAnchors => 'Total de anclajes';

  @override
  String get totalChargers => 'Total de cargadores';

  @override
  String get availableAnchors => 'Anclajes disponibles';

  @override
  String get availableChargers => 'Cargadores disponibles';

  @override
  String get rating => 'Valoración';

  @override
  String get power => 'Potencia';

  @override
  String get powerType => 'Tipo de corriente';

  @override
  String get ac => 'CA';

  @override
  String get dc => 'CC';

  @override
  String get speedType => 'Tipo de velocidad';

  @override
  String get superFast => 'Súper rápido';

  @override
  String get fast => 'Rápido';

  @override
  String get semiFast => 'Semi-rápido';

  @override
  String get connectionType => 'Tipo de conexión';

  @override
  String get chargerType => 'Tipo de cargador';

  @override
  String get css2 => 'CSS2';

  @override
  String get chademo => 'CHAdeMO';

  @override
  String get mennekes => 'Mennekes';

  @override
  String get shucko => 'Shucko';

  @override
  String get availableBikes => 'Bicicletas disponibles';

  @override
  String get electricRecharge => 'Recarga eléctrica';

  @override
  String get canAnchorBikes => 'Puede anclar bicicletas';

  @override
  String get canRentBikes => 'Puede alquilar bicicletas';

  @override
  String get state => 'Estado';

  @override
  String get availableMechanicalBikes => 'Bicicletas mecánicas disponibles';

  @override
  String get availableElectricBikes => 'Bicicletas eléctricas disponibles';

  @override
  String get operational => 'En funcionamiento';

  @override
  String get closed => 'Cerrado';

  @override
  String get occupied => 'Ocupado';

  @override
  String get unavailable => 'No disponible';

  @override
  String get connectors => 'Conectores';

  @override
  String get accessType => 'Tipo de acceso';

  @override
  String get error => 'Error';

  @override
  String get unknown => 'Desconocido';

  @override
  String get stations => 'Estaciones';

  @override
  String get saveChangesError => 'Error al guardar los cambios.';

  @override
  String get bicycle => 'Bicicleta';

  @override
  String get car => 'Coche';

  @override
  String get finishRegistration => 'Finalizar registro';

  @override
  String get userNotLoadedMessage =>
      'El usuario no se ha cargado correctamente.';

  @override
  String get information => 'Información';

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get creatingYourAccount => 'Creando tu cuenta...';

  @override
  String get errorLoadingProfile => 'Error al cargar el perfil';

  @override
  String get loadingUserProfile => 'Cargando datos del usuario...';

  @override
  String get unknownState => 'Estado desconocido';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirmLogOut => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get contactAndBioInfo => 'Información de contacto y biografía';

  @override
  String get personalInfo => 'Información personal';

  @override
  String get loading => 'Cargando...';

  @override
  String get waitAMoment => 'Espera un momento por favor';

  @override
  String get hi => 'Hola, ';

  @override
  String get ops => '¡Vaya!';

  @override
  String get account => 'Cuenta';

  @override
  String get accountDetails => 'Detalles de la cuenta';

  @override
  String get bloquedUsers => 'Usuarios bloqueados';

  @override
  String get noBloquedUsers => 'No tienes usuarios bloqueados.';

  @override
  String get unblock => 'Desbloquear';

  @override
  String get settings => 'Ajustes';

  @override
  String get appLanguage => 'Idioma de la aplicación';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get appearance => 'Apariencia';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get systemMode => 'Usar configuración del sistema';

  @override
  String get preliminarVersion => 'Versión preliminar';

  @override
  String get searchByNickname => 'Buscar por apodo';

  @override
  String get noUsersFound => 'No se encontró ningún usuario con ese apodo.';

  @override
  String get noFriendsAdded => 'Aún no tienes amigos añadidos.';

  @override
  String get results => 'RESULTADOS';

  @override
  String get yourFriends => 'TUS AMIGOS';

  @override
  String friendAdded(String nickname) {
    return '$nickname has been added to your friends.';
  }

  @override
  String get memberSince => 'Miembro desde';

  @override
  String get deleteFriendship => 'Eliminar amistad';

  @override
  String deleteFriendConfirmation(String nickname) {
    return '¿Estás seguro de que quieres eliminar a $nickname de tus amigos?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String deletedFriend(String nickname) {
    return 'Has eliminado a $nickname de tus amigos.';
  }

  @override
  String get deleteFriend => 'Eliminar amistad';

  @override
  String get blockUser => 'Bloquear usuario';

  @override
  String blockUserConfirmation(String nickname) {
    return '¿Estás seguro de que quieres bloquear a $nickname? No podrás ver su perfil ni interactuar con él.';
  }

  @override
  String get block => 'Bloquear';

  @override
  String get friends => 'Amigos';

  @override
  String get addFriend => 'Añadir amigo';

  @override
  String get minCharsSearchHint =>
      'Por favor, introduce al menos 3 caracteres para buscar.';

  @override
  String get anyStationsFound =>
      'No se han encontrado resultados para tu búsqueda.';

  @override
  String get errorSavingRoute => 'Error al guardar la ruta';

  @override
  String get notEnoughPointsToRecordTrack =>
      'No se han registrado suficientes puntos para guardar la ruta grabada.';

  @override
  String get howToGetThere => 'Cómo llegar';

  @override
  String get routeHistory => 'Historial de recorridos grabados';

  @override
  String get noRoutesFound => 'No se han encontrado rutas grabadas.';

  @override
  String get distance => 'Distancia';

  @override
  String get avgSpeed => 'Velocidad media';

  @override
  String get routeStatistics => 'Estadísticas de la ruta';

  @override
  String get noRouteDataAvailable => 'No hay datos de la ruta disponibles.';

  @override
  String get routeRecording => 'Grabación de la ruta';

  @override
  String get duration => 'Duración';

  @override
  String get averageSpeed => 'Velocidad media';

  @override
  String get maxSpeed => 'Velocidad máxima';

  @override
  String get elevation => 'Elevación';

  @override
  String get elevationGain => 'Ganancia de elevación';

  @override
  String get elevationLoss => 'Pérdida de elevación';

  @override
  String get environmentalImpact => 'Impacto ambiental';

  @override
  String get co2Saved => 'CO₂ ahorrado';

  @override
  String get caloriesBurned => 'Calorías quemadas';

  @override
  String get currentSpeed => 'Velocidad actual';

  @override
  String get stopRecording => 'Detener grabación';

  @override
  String get opinions => 'Valoraciones';

  @override
  String get unknownPower => 'Potencia desconocida';

  @override
  String get station => 'Estación';

  @override
  String get seeOpinions => 'Ver reviews';

  @override
  String get withoutOpinions => 'Sin reviews';

  @override
  String get rate => 'Valorar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get normal => 'Normal';

  @override
  String get mechanical => 'Mecánicas';

  @override
  String get electric => 'Eléctricas';

  @override
  String get free => 'Libres';

  @override
  String get available => 'Disponible';

  @override
  String get charge => 'Carga';

  @override
  String get reviewStation => 'Valorar estación';

  @override
  String get writeYourOpinion => 'Escribe tu opinión (opcional)';

  @override
  String get sendReview => 'Enviar valoración';

  @override
  String get excellent => 'Excelente';

  @override
  String get veryGood => 'Muy buena';

  @override
  String get good => 'Buena';

  @override
  String get regular => 'Regular';

  @override
  String get bad => 'Mala';

  @override
  String get thankYouForYourReview => '¡Gracias por tu valoración!';

  @override
  String get errorLoadingReviews => 'Error al cargar las valoraciones';

  @override
  String get retry => 'Reintentar';

  @override
  String get firstToReview => '¡Sé el primero en valorar esta estación!';

  @override
  String get editReview => 'Editar valoración';

  @override
  String get sureActionConfirmation =>
      'Esta acción no se puede deshacer. ¿Estás seguro de que quieres continuar?';

  @override
  String get deletedReview => 'Has eliminado tu valoración.';

  @override
  String get updateReview => 'Actualizar valoración';

  @override
  String get updatedReview => 'Tu valoración ha sido actualizada.';

  @override
  String get needsToSignInWithGoogle =>
      'Este correo electrónico está registrado con Google. Por favor, inicia sesión con Google.';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirmation =>
      '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer y se perderán todos tus datos.';

  @override
  String get accountDeleted => 'Tu cuenta ha sido eliminada correctamente.';

  @override
  String get errorDeletingAccount => 'Error al eliminar la cuenta.';

  @override
  String get accountDeletedSuccessfully =>
      'La cuenta se ha eliminado correctamente.';

  @override
  String get userMismatch => 'El usuario no coincide con el usuario actual.';

  @override
  String get start => 'Iniciar';

  @override
  String get estTime => 'Tiempo estimado';

  @override
  String get uLoc => 'Tu ubicación';

  @override
  String get social => 'Social';

  @override
  String get accountSuspendedMessage => 'Tu cuenta ha sido suspendida.';

  @override
  String get accountSuspended => 'Cuenta suspendida';

  @override
  String get suspensionReason => 'Motivo de la suspensión';

  @override
  String get communityGuidelinesViolation =>
      'Violación de las normas de la comunidad';

  @override
  String get needHelp => '¿Necesitas ayuda?';

  @override
  String get contactSupport => 'Contacta con soporte';

  @override
  String get reviewCommunityGuidelines =>
      'Revisa nuestras normas de comunidad para evitar futuras suspensiones.';

  @override
  String get description => 'Descripción';

  @override
  String get days => 'días';

  @override
  String get hours => 'horas';

  @override
  String get minutes => 'minutos';

  @override
  String get permanent => 'Permanente';
}
