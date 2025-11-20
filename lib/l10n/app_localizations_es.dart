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
  String get userDataPreferences => 'Acaba de completar tu perfil';

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
  String get userDescription => 'Descripción (opcional)';

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
  String get available => 'Disponible';

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
  String get unknownPower => 'Potencia desconocida';

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
}
