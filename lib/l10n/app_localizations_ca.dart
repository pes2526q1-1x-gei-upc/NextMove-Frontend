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
  String get wrongPassword =>
      'La contrasenya és incorrecta. Si has utilitzat aquesta adreça de correu electrònic per registrar-te amb Google, inicia sessió amb Google.';

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

  @override
  String errorOccurred(String error) {
    return 'Ha ocorregut un error: $error';
  }

  @override
  String get unknownError => 'Error desconegut';

  @override
  String get searchStation => 'Cerca una estació...';

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
  String get available => 'Disponibles';

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

  @override
  String get saveChangesError => 'Error al desar els canvis.';

  @override
  String get bicycle => 'Bicicleta';

  @override
  String get car => 'Cotxe';

  @override
  String get finishRegistration => 'Finalitzar registre';

  @override
  String get userNotLoadedMessage =>
      'L\'usuari no s\'ha carregat correctament.';

  @override
  String get information => 'Informació';

  @override
  String get logOut => 'Tancar sessió';

  @override
  String get creatingYourAccount => 'Creant el teu compte...';

  @override
  String get errorLoadingProfile => 'Error en carregar el perfil';

  @override
  String get loadingUserProfile => 'Carregant dades de l\'usuari...';

  @override
  String get unknownState => 'Estat desconegut';

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get confirmLogOut => 'Estàs segur que vols tancar la sessió?';

  @override
  String get contactAndBioInfo => 'Informació de contacte i biografia';

  @override
  String get personalInfo => 'Informació personal';

  @override
  String get loading => 'Carregant...';

  @override
  String get waitAMoment => 'Si us plau, espera un moment';

  @override
  String get hi => 'Hola, ';

  @override
  String get ops => 'Vaja!';

  @override
  String get account => 'Compte';

  @override
  String get accountDetails => 'Detalls del compte';

  @override
  String get bloquedUsers => 'Usuaris bloquejats';

  @override
  String get noBloquedUsers => 'No tens usuaris bloquejats.';

  @override
  String get unblock => 'Desbloquejar';

  @override
  String get settings => 'Configuració';

  @override
  String get appLanguage => 'Idioma de l\'aplicació';

  @override
  String get notifications => 'Notificacions';

  @override
  String get appearance => 'Aparença';

  @override
  String get lightMode => 'Mode clar';

  @override
  String get darkMode => 'Mode fosc';

  @override
  String get preliminarVersion => 'Versió preliminar';

  @override
  String get searchByNickname => 'Cerca per sobrenom';

  @override
  String get noUsersFound => 'No s\'ha trobat cap usuari amb aquest sobrenom.';

  @override
  String get noFriendsAdded => 'Encara no tens amics afegits.';

  @override
  String get results => 'RESULTATS';

  @override
  String get yourFriends => 'ELS TEUS AMICS';

  @override
  String friendAdded(String nickname) {
    return '$nickname s\'ha afegit als teus amics.';
  }

  @override
  String get friends => 'Amics';

  @override
  String get memberSince => 'Membre des de';

  @override
  String get deleteFriendship => 'Eliminar amistat';

  @override
  String deleteFriendConfirmation(String nickname) {
    return 'Estàs segur que vols eliminar $nickname dels teus amics?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String deletedFriend(String nickname) {
    return '$nickname ha estat eliminat dels teus amics.';
  }

  @override
  String get deleteFriend => 'Eliminar amistat';

  @override
  String get blockUser => 'Bloquejar usuari';

  @override
  String blockUserConfirmation(String nickname) {
    return 'Estàs segur que vols bloquejar $nickname? Això eliminarà l\'amistat i no podreu veure els perfils mútuament.';
  }

  @override
  String get block => 'Bloquejar';

  @override
  String get minCharsSearchHint =>
      'Si us plau, introdueix almenys 3 caràcters per cercar.';

  @override
  String get anyStationsFound =>
      'No s\'han trobat resultats per a la teva cerca.';

  @override
  String get errorSavingRoute => 'Error en desar la ruta';

  @override
  String get notEnoughPointsToRecordTrack =>
      'No s\'han gravat prou punts per desar la ruta enregistrada.';

  @override
  String get howToGetThere => 'Indicacions';

  @override
  String get routeHistory => 'Historial de recorreguts enregistrats';

  @override
  String get noRoutesFound => 'No s\'han trobat recorreguts enregistrats.';

  @override
  String get distance => 'Distància';

  @override
  String get avgSpeed => 'Velocitat mitjana';

  @override
  String get routeStatistics => 'Estadístiques de la ruta';

  @override
  String get noRouteDataAvailable => 'No hi ha dades de ruta disponibles.';

  @override
  String get routeRecording => 'Gravació de ruta';

  @override
  String get duration => 'Durada';

  @override
  String get averageSpeed => 'Velocitat mitjana';

  @override
  String get maxSpeed => 'Velocitat màxima';

  @override
  String get elevation => 'Elevació';

  @override
  String get elevationGain => 'Guany d\'elevació';

  @override
  String get elevationLoss => 'Pèrdua d\'elevació';

  @override
  String get environmentalImpact => 'Impacte ambiental';

  @override
  String get co2Saved => 'CO₂ estalviat';

  @override
  String get caloriesBurned => 'Calories cremades';

  @override
  String get currentSpeed => 'Velocitat actual';

  @override
  String get stopRecording => 'Aturar la gravació';

  @override
  String get opinions => 'Valoracions';

  @override
  String get station => 'Estació';

  @override
  String get seeOpinions => 'Veure valoracions';

  @override
  String get withoutOpinions => 'Sense valoracions';

  @override
  String get rate => 'Valorar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get normal => 'Normal';

  @override
  String get mechanical => 'Mecànicas';

  @override
  String get electric => 'Elèctriques';

  @override
  String get free => 'Lliures';

  @override
  String get charge => 'Càrrega';

  @override
  String get reviewStation => 'Valorar Estació';

  @override
  String get writeYourOpinion => 'Escriu la teva opinió (opcional)';

  @override
  String get sendReview => 'Enviar valoració';

  @override
  String get excellent => 'Excel·lent';

  @override
  String get veryGood => 'Molt bé';

  @override
  String get good => 'Bé';

  @override
  String get regular => 'Regular';

  @override
  String get bad => 'Malament';

  @override
  String get thankYouForYourReview => 'Gràcies per la teva valoració!';

  @override
  String get errorLoadingReviews => 'Error en carregar les valoracions';

  @override
  String get retry => 'Reintentar';

  @override
  String get firstToReview => 'Sigues el primer a valorar aquesta estació!';

  @override
  String get editReview => 'Editar valoració';

  @override
  String get sureActionConfirmation =>
      'Aquesta acció no es pot desfer. Estàs segur que vols continuar?';

  @override
  String get deletedReview => 'Has eliminat la teva valoració.';

  @override
  String get updateReview => 'Actualitzar valoració';

  @override
  String get updatedReview => 'La teva valoració ha estat actualitzada.';

  @override
  String get needsToSignInWithGoogle =>
      'Aquest correu electrònic està registrat amb Google. Si us plau, inicia sessió amb Google.';

  @override
  String get deleteAccount => 'Eliminar compte';

  @override
  String get deleteAccountConfirmation =>
      'Estàs segur que vols eliminar el teu compte? Aquesta acció no es pot desfer i es perdran totes les teves dades.';

  @override
  String get accountDeleted => 'El teu compte ha estat eliminat correctament.';

  @override
  String get errorDeletingAccount => 'Error en eliminar el compte.';

  @override
  String get accountDeletedSuccessfully =>
      'El compte s\'ha eliminat correctament.';

  @override
  String get userMismatch => 'L\'usuari no coincideix amb l\'usuari actual.';

  @override
  String get start => 'Iniciar';

  @override
  String get estTime => 'Temps estimat';

  @override
  String get uLoc => 'La Teva Ubicació';
}
