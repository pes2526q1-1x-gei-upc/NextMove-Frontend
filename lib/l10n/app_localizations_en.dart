// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get register => 'Sign up';

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

  @override
  String welcomeTo(String appName) {
    return 'Welcome to $appName!';
  }

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get useEmail => 'Use email';

  @override
  String get whatIsYourEmailAddress => 'What is your email address?';

  @override
  String get continue_ => 'Continue';

  @override
  String get needsToRegister =>
      'We haven\'t found a user with that email. You will now need to sign up with a new password.';

  @override
  String get invalidEmail => 'The email address format is invalid.';

  @override
  String get passwordRequirements =>
      'The password must be at least 8 characters long with 1 lowercase, 1 uppercase, 1 number, and 1 special character.';

  @override
  String get signIn => 'Sign in';

  @override
  String get passwordTooShort =>
      'The password must be at least 8 characters long.';

  @override
  String get passwordNeedsLowercase =>
      'The password must contain at least 1 lowercase letter.';

  @override
  String get passwordNeedsUppercase =>
      'The password must contain at least 1 uppercase letter.';

  @override
  String get passwordNeedsNumber =>
      'The password must contain at least 1 number.';

  @override
  String get passwordNeedsSpecialCharacter =>
      'The password must contain at least 1 special character.';

  @override
  String get wrongPassword => 'The password is incorrect.';

  @override
  String errorOccurred(String error) {
    return 'An error has occurred: $error';
  }

  @override
  String get unknownError => 'Unknown error';

  @override
  String get searchStation => 'Search for a station...';
  String get address => 'Address';

  @override
  String get totalAnchors => 'Total anchors';

  @override
  String get totalChargers => 'Total chargers';

  @override
  String get availableAnchors => 'Available anchors';

  @override
  String get availableChargers => 'Available chargers';

  @override
  String get rating => 'Rating';

  @override
  String get power => 'Power';

  @override
  String get powerType => 'Power type';

  @override
  String get ac => 'AC';

  @override
  String get dc => 'DC';

  @override
  String get speedType => 'Speed type';

  @override
  String get superFast => 'Super fast';

  @override
  String get fast => 'Fast';

  @override
  String get semiFast => 'Semi-fast';

  @override
  String get connectionType => 'Connection type';

  @override
  String get chargerType => 'Charger type';

  @override
  String get css2 => 'CSS2';

  @override
  String get chademo => 'CHAdeMO';

  @override
  String get mennekes => 'Mennekes';

  @override
  String get shucko => 'Shucko';

  @override
  String get availableBikes => 'Available bikes';

  @override
  String get electricRecharge => 'Electric recharge';

  @override
  String get canAnchorBikes => 'Can anchor bikes';

  @override
  String get canRentBikes => 'Can rent bikes';

  @override
  String get state => 'State';

  @override
  String get availableMechanicalBikes => 'Available mechanical bikes';

  @override
  String get availableElectricBikes => 'Available electric bikes';

  @override
  String get operational => 'Operational';

  @override
  String get closed => 'Closed';

  @override
  String get available => 'Available';

  @override
  String get occupied => 'Occupied';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get connectors => 'Connectors';

  @override
  String get accessType => 'Access type';

  @override
  String get error => 'Error';

  @override
  String get unknownPower => 'Unknown power';

  @override
  String get unknown => 'Unknown';

  @override
  String get stations => 'Stations';
}
