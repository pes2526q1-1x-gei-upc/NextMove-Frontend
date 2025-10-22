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

  @override
  String get userDataPreferences => 'Acaba de completar el teu perfil';

  @override
  String get nickname => 'Sobrenom';

  @override
  String get nicknameHint => 'Introdueix el teu sobrenom';

  @override
  String get birthdate => 'Data de naixement';

  @override
  String get bithdateHint => 'Ex: 1990-01-01';

  @override
  String get mandatoryBirthDate => 'La data de naixement és obligatòria';

  @override
  String get invalidBirthDateFormat =>
      'Format de data invàlid. Utilitza YYYY-MM-DD';

  @override
  String get telephoneNumber => 'Número de telèfon';

  @override
  String get preferredLanguage => 'Idioma preferit';

  @override
  String get userDescription => 'Descripció';

  @override
  String get userDescriptionHint => 'Introdueix una breu descripció sobre tu';

  @override
  String get preferredMode => 'Mode preferit';

  @override
  String get saveChanges => 'Desa els canvis';

  @override
  String get camera => 'Càmera';

  @override
  String get gallery => 'Galeria';

  @override
  String get imagePickerError =>
      'S\'ha produït un error en seleccionar la imatge.';

  @override
  String get saveChangesFeedback => 'Canvis desats correctament.';

  @override
  String get formError => 'Si us plau, corregeix els errors abans de desar.';

  @override
  String get mandatoryNickname => 'El sobrenom és obligatori';

  @override
  String get mandatoryPhoneNumber => 'El número de telèfon és obligatori';

  @override
  String get invalidPhoneNumber => 'Format de número de telèfon invàlid';

  @override
  String get mandatoryPreferredMode => 'El mode preferit és obligatori';

  @override
  String get editProfile => 'Edita el perfil';

  @override
  String get nicknameNonEditable => 'Sobrenom';

  @override
  String get fullName => 'Nom complet';

  @override
  String get mandatoryFullName => 'El nom complet és obligatori';
}
