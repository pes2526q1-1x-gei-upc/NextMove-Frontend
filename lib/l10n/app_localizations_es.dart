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
  String get wrongPassword => 'La contraseña es incorrecta.';

  @override
  String errorOccurred(String error) {
    return 'Ha ocurrido un error: $error';
  }

  @override
  String get unknownError => 'Error desconocido';

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
}
