// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get register => 'Registrar-se';

  @override
  String get emailAddress => 'Adreça de correu electrònic';

  @override
  String get password => 'Contrasenya';

  @override
  String welcomeTo(String appName) {
    return 'Benvingut a $appName!';
  }

  @override
  String get signInWithGoogle => 'Iniciar sessió amb Google';

  @override
  String get useEmail => 'Utilitzar el correu electrònic';

  @override
  String get whatIsYourEmailAddress =>
      'Quina és la teva adreça de correu electrònic?';

  @override
  String get continue_ => 'Continuar';

  @override
  String get needsToRegister =>
      'No hem trobat cap usuari amb aquest correu electrònic. Ara hauràs de registrar-te amb una nova contrasenya.';

  @override
  String get invalidEmail =>
      'El format de l\'adreça de correu electrònic és invàlid.';

  @override
  String get passwordRequirements =>
      'La contrasenya ha de tenir almenys 8 caràcters amb 1 minúscula, 1 majúscula, 1 nombre i 1 caràcter especial.';

  @override
  String get signIn => 'Iniciar sessió';

  @override
  String get passwordTooShort =>
      'La contrasenya ha de tenir almenys 8 caràcters.';

  @override
  String get passwordNeedsLowercase =>
      'La contrasenya ha de tenir almenys 1 lletra minúscula.';

  @override
  String get passwordNeedsUppercase =>
      'La contrasenya ha de tenir almenys 1 lletra majúscula.';

  @override
  String get passwordNeedsNumber =>
      'La contrasenya ha de tenir almenys 1 número.';

  @override
  String get passwordNeedsSpecialCharacter =>
      'La contrasenya ha de tenir almenys 1 caràcter especial.';

  @override
  String get wrongPassword => 'La contrasenya és incorrecta.';
}
