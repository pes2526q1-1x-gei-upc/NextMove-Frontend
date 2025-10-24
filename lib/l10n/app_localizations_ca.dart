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
  String errorOccurred(String error) {
    return 'Ha ocorregut un error: $error';
  }

  @override
  String get unknownError => 'Error desconegut';

  @override
  String get address => 'Adreça';

  @override
  String get totalAnchors => 'Total d\'ancoratges';

  @override
  String get totalChargers => 'Total de carregadors';

  @override
  String get availableAnchors => 'Ancoratges disponibles';

  @override
  String get availableChargers => 'Carregadors disponibles';

  @override
  String get rating => 'Valoració';

  @override
  String get power => 'Potència';

  @override
  String get powerType => 'Tipus de corrent';

  @override
  String get ac => 'CA';

  @override
  String get dc => 'CC';

  @override
  String get speedType => 'Tipus de velocitat';

  @override
  String get superFast => 'Superràpid';

  @override
  String get fast => 'Ràpid';

  @override
  String get semiFast => 'Semi-ràpid';

  @override
  String get connectionType => 'Tipus de connexió';

  @override
  String get chargerType => 'Tipus de carregador';

  @override
  String get css2 => 'CSS2';

  @override
  String get chademo => 'CHAdeMO';

  @override
  String get mennekes => 'Mennekes';

  @override
  String get shucko => 'Shucko';

  @override
  String get availableBikes => 'Bicicletes disponibles';

  @override
  String get electricRecharge => 'Recàrrega elèctrica';

  @override
  String get canAnchorBikes => 'Es poden ancorar bicicletes';

  @override
  String get canRentBikes => 'Es poden llogar bicicletes';

  @override
  String get state => 'Estat';

  @override
  String get availableMechanicalBikes => 'Bicicletes mecàniques disponibles';

  @override
  String get availableElectricBikes => 'Bicicletes elèctriques disponibles';

  @override
  String get operational => 'En funcionament';

  @override
  String get closed => 'Tancat';

  @override
  String get available => 'Disponible';

  @override
  String get occupied => 'Ocupat';

  @override
  String get unavailable => 'No disponible';

  @override
  String get connectors => 'Connectors';

  @override
  String get accessType => 'Tipus d\'accés';

  @override
  String get error => 'Error';

  @override
  String get unknownPower => 'Potència desconeguda';

  @override
  String get unknown => 'Desconegut';

  @override
  String get stations => 'Estacions';
}
