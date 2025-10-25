import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get register;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {appName}!'**
  String welcomeTo(String appName);

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @useEmail.
  ///
  /// In en, this message translates to:
  /// **'Use email'**
  String get useEmail;

  /// No description provided for @whatIsYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'What is your email address?'**
  String get whatIsYourEmailAddress;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @needsToRegister.
  ///
  /// In en, this message translates to:
  /// **'We haven\'t found a user with that email. You will now need to sign up with a new password.'**
  String get needsToRegister;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address format is invalid.'**
  String get invalidEmail;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 8 characters long with 1 lowercase, 1 uppercase, 1 number, and 1 special character.'**
  String get passwordRequirements;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 8 characters long.'**
  String get passwordTooShort;

  /// No description provided for @passwordNeedsLowercase.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 1 lowercase letter.'**
  String get passwordNeedsLowercase;

  /// No description provided for @passwordNeedsUppercase.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 1 uppercase letter.'**
  String get passwordNeedsUppercase;

  /// No description provided for @passwordNeedsNumber.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 1 number.'**
  String get passwordNeedsNumber;

  /// No description provided for @passwordNeedsSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 1 special character.'**
  String get passwordNeedsSpecialCharacter;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is incorrect.'**
  String get wrongPassword;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred: {error}'**
  String errorOccurred(String error);

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @searchStation.
  ///
  /// In en, this message translates to:
  /// **'Search for a station...'**
  String get searchStation;
  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @totalAnchors.
  ///
  /// In en, this message translates to:
  /// **'Total anchors'**
  String get totalAnchors;

  /// No description provided for @totalChargers.
  ///
  /// In en, this message translates to:
  /// **'Total chargers'**
  String get totalChargers;

  /// No description provided for @availableAnchors.
  ///
  /// In en, this message translates to:
  /// **'Available anchors'**
  String get availableAnchors;

  /// No description provided for @availableChargers.
  ///
  /// In en, this message translates to:
  /// **'Available chargers'**
  String get availableChargers;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @powerType.
  ///
  /// In en, this message translates to:
  /// **'Power type'**
  String get powerType;

  /// No description provided for @ac.
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get ac;

  /// No description provided for @dc.
  ///
  /// In en, this message translates to:
  /// **'DC'**
  String get dc;

  /// No description provided for @speedType.
  ///
  /// In en, this message translates to:
  /// **'Speed type'**
  String get speedType;

  /// No description provided for @superFast.
  ///
  /// In en, this message translates to:
  /// **'Super fast'**
  String get superFast;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @semiFast.
  ///
  /// In en, this message translates to:
  /// **'Semi-fast'**
  String get semiFast;

  /// No description provided for @connectionType.
  ///
  /// In en, this message translates to:
  /// **'Connection type'**
  String get connectionType;

  /// No description provided for @chargerType.
  ///
  /// In en, this message translates to:
  /// **'Charger type'**
  String get chargerType;

  /// No description provided for @css2.
  ///
  /// In en, this message translates to:
  /// **'CSS2'**
  String get css2;

  /// No description provided for @chademo.
  ///
  /// In en, this message translates to:
  /// **'CHAdeMO'**
  String get chademo;

  /// No description provided for @mennekes.
  ///
  /// In en, this message translates to:
  /// **'Mennekes'**
  String get mennekes;

  /// No description provided for @shucko.
  ///
  /// In en, this message translates to:
  /// **'Shucko'**
  String get shucko;

  /// No description provided for @availableBikes.
  ///
  /// In en, this message translates to:
  /// **'Available bikes'**
  String get availableBikes;

  /// No description provided for @electricRecharge.
  ///
  /// In en, this message translates to:
  /// **'Electric recharge'**
  String get electricRecharge;

  /// No description provided for @canAnchorBikes.
  ///
  /// In en, this message translates to:
  /// **'Can anchor bikes'**
  String get canAnchorBikes;

  /// No description provided for @canRentBikes.
  ///
  /// In en, this message translates to:
  /// **'Can rent bikes'**
  String get canRentBikes;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @availableMechanicalBikes.
  ///
  /// In en, this message translates to:
  /// **'Available mechanical bikes'**
  String get availableMechanicalBikes;

  /// No description provided for @availableElectricBikes.
  ///
  /// In en, this message translates to:
  /// **'Available electric bikes'**
  String get availableElectricBikes;

  /// No description provided for @operational.
  ///
  /// In en, this message translates to:
  /// **'Operational'**
  String get operational;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @occupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupied;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @connectors.
  ///
  /// In en, this message translates to:
  /// **'Connectors'**
  String get connectors;

  /// No description provided for @accessType.
  ///
  /// In en, this message translates to:
  /// **'Access type'**
  String get accessType;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @unknownPower.
  ///
  /// In en, this message translates to:
  /// **'Unknown power'**
  String get unknownPower;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @stations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stations;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
