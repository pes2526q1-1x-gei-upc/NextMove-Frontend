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
}
