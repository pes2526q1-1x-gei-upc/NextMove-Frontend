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

  /// No description provided for @userDataPreferences.
  ///
  /// In en, this message translates to:
  /// **'Finish your profile'**
  String get userDataPreferences;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname *'**
  String get nickname;

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your nickname'**
  String get nicknameHint;

  /// No description provided for @birthdate.
  ///
  /// In en, this message translates to:
  /// **'Birthdate'**
  String get birthdate;

  /// No description provided for @bithdateHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: 1990-01-01'**
  String get bithdateHint;

  /// No description provided for @mandatoryBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birthdate is mandatory'**
  String get mandatoryBirthDate;

  /// No description provided for @invalidBirthDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid date format. Use YYYY-MM-DD'**
  String get invalidBirthDateFormat;

  /// No description provided for @telephoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Telephone number'**
  String get telephoneNumber;

  /// No description provided for @preferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get preferredLanguage;

  /// No description provided for @userDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get userDescription;

  /// No description provided for @userDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a brief description about yourself'**
  String get userDescriptionHint;

  /// No description provided for @preferredMode.
  ///
  /// In en, this message translates to:
  /// **'Preferred mode *'**
  String get preferredMode;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @imagePickerError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while selecting the image.'**
  String get imagePickerError;

  /// No description provided for @saveChangesFeedback.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully.'**
  String get saveChangesFeedback;

  /// No description provided for @formError.
  ///
  /// In en, this message translates to:
  /// **'Please correct the errors before saving.'**
  String get formError;

  /// No description provided for @mandatoryNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname is mandatory'**
  String get mandatoryNickname;

  /// No description provided for @mandatoryPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Telephone number is mandatory'**
  String get mandatoryPhoneNumber;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid telephone number format'**
  String get invalidPhoneNumber;

  /// No description provided for @mandatoryPreferredMode.
  ///
  /// In en, this message translates to:
  /// **'Preferred mode is mandatory'**
  String get mandatoryPreferredMode;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @nicknameNonEditable.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameNonEditable;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;
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
