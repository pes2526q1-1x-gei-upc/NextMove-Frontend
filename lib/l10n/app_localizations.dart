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
  /// **'The password is incorrect. If you used this email address to sign up with Google, please sign in with Google.'**
  String get wrongPassword;

  /// No description provided for @userDataPreferences.
  ///
  /// In en, this message translates to:
  /// **'Finish your profile'**
  String get userDataPreferences;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
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
  /// **'Preferred mode'**
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

  /// No description provided for @mandatoryFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name is mandatory'**
  String get mandatoryFullName;

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

  /// No description provided for @saveChangesError.
  ///
  /// In en, this message translates to:
  /// **'Error saving changes.'**
  String get saveChangesError;

  /// No description provided for @bicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get bicycle;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @finishRegistration.
  ///
  /// In en, this message translates to:
  /// **'Finish registration'**
  String get finishRegistration;

  /// No description provided for @userNotLoadedMessage.
  ///
  /// In en, this message translates to:
  /// **'The user has not been loaded correctly.'**
  String get userNotLoadedMessage;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @creatingYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating your account...'**
  String get creatingYourAccount;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @loadingUserProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading user profile...'**
  String get loadingUserProfile;

  /// No description provided for @unknownState.
  ///
  /// In en, this message translates to:
  /// **'Unknown state'**
  String get unknownState;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogOut;

  /// No description provided for @contactAndBioInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact and bio information'**
  String get contactAndBioInfo;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @waitAMoment.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment'**
  String get waitAMoment;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi, '**
  String get hi;

  /// No description provided for @ops.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get ops;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get accountDetails;

  /// No description provided for @bloquedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get bloquedUsers;

  /// No description provided for @noBloquedUsers.
  ///
  /// In en, this message translates to:
  /// **'You have no blocked users.'**
  String get noBloquedUsers;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @preliminarVersion.
  ///
  /// In en, this message translates to:
  /// **'Preliminary version'**
  String get preliminarVersion;

  /// No description provided for @searchByNickname.
  ///
  /// In en, this message translates to:
  /// **'Search by nickname'**
  String get searchByNickname;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with that nickname.'**
  String get noUsersFound;

  /// No description provided for @noFriendsAdded.
  ///
  /// In en, this message translates to:
  /// **'You have no friends added yet.'**
  String get noFriendsAdded;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'RESULTS'**
  String get results;

  /// No description provided for @yourFriends.
  ///
  /// In en, this message translates to:
  /// **'YOUR FRIENDS'**
  String get yourFriends;

  /// No description provided for @friendAdded.
  ///
  /// In en, this message translates to:
  /// **'{nickname} has been added to your friends.'**
  String friendAdded(String nickname);

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @deleteFriendship.
  ///
  /// In en, this message translates to:
  /// **'Delete friendship'**
  String get deleteFriendship;

  /// No description provided for @deleteFriendConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {nickname} from your friends?'**
  String deleteFriendConfirmation(String nickname);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deletedFriend.
  ///
  /// In en, this message translates to:
  /// **'You have deleted {nickname} from your friends.'**
  String deletedFriend(String nickname);

  /// No description provided for @deleteFriend.
  ///
  /// In en, this message translates to:
  /// **'Delete friendship'**
  String get deleteFriend;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUser;

  /// No description provided for @blockUserConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block {nickname}? You won\'t be able to see their profile or interact with them.'**
  String blockUserConfirmation(String nickname);

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @minCharsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least 3 characters to search.'**
  String get minCharsSearchHint;

  /// No description provided for @anyStationsFound.
  ///
  /// In en, this message translates to:
  /// **'No results were found for your search.'**
  String get anyStationsFound;

  /// No description provided for @errorSavingRoute.
  ///
  /// In en, this message translates to:
  /// **'Error saving route'**
  String get errorSavingRoute;

  /// No description provided for @notEnoughPointsToRecordTrack.
  ///
  /// In en, this message translates to:
  /// **'Not enough points were recorded to save the recorded route.'**
  String get notEnoughPointsToRecordTrack;

  /// No description provided for @howToGetThere.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get howToGetThere;

  /// No description provided for @routeHistory.
  ///
  /// In en, this message translates to:
  /// **'Recorded route history'**
  String get routeHistory;

  /// No description provided for @noRoutesFound.
  ///
  /// In en, this message translates to:
  /// **'No recorded routes were found.'**
  String get noRoutesFound;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @avgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Average speed'**
  String get avgSpeed;

  /// No description provided for @routeStatistics.
  ///
  /// In en, this message translates to:
  /// **'Route statistics'**
  String get routeStatistics;

  /// No description provided for @noRouteDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No route data available.'**
  String get noRouteDataAvailable;

  /// No description provided for @routeRecording.
  ///
  /// In en, this message translates to:
  /// **'Route recording'**
  String get routeRecording;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @averageSpeed.
  ///
  /// In en, this message translates to:
  /// **'Average speed'**
  String get averageSpeed;

  /// No description provided for @maxSpeed.
  ///
  /// In en, this message translates to:
  /// **'Max speed'**
  String get maxSpeed;

  /// No description provided for @elevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get elevation;

  /// No description provided for @elevationGain.
  ///
  /// In en, this message translates to:
  /// **'Elevation gain'**
  String get elevationGain;

  /// No description provided for @elevationLoss.
  ///
  /// In en, this message translates to:
  /// **'Elevation loss'**
  String get elevationLoss;

  /// No description provided for @environmentalImpact.
  ///
  /// In en, this message translates to:
  /// **'Environmental impact'**
  String get environmentalImpact;

  /// No description provided for @co2Saved.
  ///
  /// In en, this message translates to:
  /// **'CO₂ saved'**
  String get co2Saved;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories burned'**
  String get caloriesBurned;

  /// No description provided for @currentSpeed.
  ///
  /// In en, this message translates to:
  /// **'Current speed'**
  String get currentSpeed;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopRecording;

  /// No description provided for @opinions.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get opinions;

  /// No description provided for @station.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get station;

  /// No description provided for @seeOpinions.
  ///
  /// In en, this message translates to:
  /// **'See reviews'**
  String get seeOpinions;

  /// No description provided for @withoutOpinions.
  ///
  /// In en, this message translates to:
  /// **'Without reviews'**
  String get withoutOpinions;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @mechanical.
  ///
  /// In en, this message translates to:
  /// **'Mechanical'**
  String get mechanical;

  /// No description provided for @electric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get electric;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @charge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get charge;

  /// No description provided for @reviewStation.
  ///
  /// In en, this message translates to:
  /// **'Review Station'**
  String get reviewStation;

  /// No description provided for @writeYourOpinion.
  ///
  /// In en, this message translates to:
  /// **'Write your opinion (optional)'**
  String get writeYourOpinion;

  /// No description provided for @sendReview.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get sendReview;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get veryGood;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @regular.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get regular;

  /// No description provided for @bad.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get bad;

  /// No description provided for @thankYouForYourReview.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review!'**
  String get thankYouForYourReview;

  /// No description provided for @errorLoadingReviews.
  ///
  /// In en, this message translates to:
  /// **'Error loading reviews'**
  String get errorLoadingReviews;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @firstToReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review this station!'**
  String get firstToReview;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit review'**
  String get editReview;

  /// No description provided for @sureActionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure you want to proceed?'**
  String get sureActionConfirmation;

  /// No description provided for @deletedReview.
  ///
  /// In en, this message translates to:
  /// **'You have deleted your review.'**
  String get deletedReview;

  /// No description provided for @updateReview.
  ///
  /// In en, this message translates to:
  /// **'Update review'**
  String get updateReview;

  /// No description provided for @updatedReview.
  ///
  /// In en, this message translates to:
  /// **'Your review has been updated.'**
  String get updatedReview;

  /// No description provided for @needsToSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'This email is registered with Google. Please sign in with Google.'**
  String get needsToSignInWithGoogle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all your data will be lost.'**
  String get deleteAccountConfirmation;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted.'**
  String get accountDeleted;

  /// No description provided for @errorDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account.'**
  String get errorDeletingAccount;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The account has been deleted successfully.'**
  String get accountDeletedSuccessfully;

  /// No description provided for @userMismatch.
  ///
  /// In en, this message translates to:
  /// **'The user does not match the current user.'**
  String get userMismatch;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @estTime.
  ///
  /// In en, this message translates to:
  /// **'Travel time'**
  String get estTime;

  /// No description provided for @uLoc.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get uLoc;
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
