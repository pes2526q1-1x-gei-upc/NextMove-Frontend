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
  String get userDataPreferences => 'Finish your profile';

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknameHint => 'Enter your nickname';

  @override
  String get birthdate => 'Birthdate';

  @override
  String get bithdateHint => 'Ex: 1990-01-01';

  @override
  String get mandatoryBirthDate => 'Birthdate is mandatory';

  @override
  String get invalidBirthDateFormat => 'Invalid date format. Use YYYY-MM-DD';

  @override
  String get telephoneNumber => 'Telephone number';

  @override
  String get preferredLanguage => 'Preferred language';

  @override
  String get userDescription => 'Description';

  @override
  String get userDescriptionHint => 'Enter a brief description about yourself';

  @override
  String get preferredMode => 'Preferred mode';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get imagePickerError => 'An error occurred while selecting the image.';

  @override
  String get saveChangesFeedback => 'Changes saved successfully.';

  @override
  String get formError => 'Please correct the errors before saving.';

  @override
  String get mandatoryNickname => 'Nickname is mandatory';

  @override
  String get mandatoryPhoneNumber => 'Telephone number is mandatory';

  @override
  String get invalidPhoneNumber => 'Invalid telephone number format';

  @override
  String get mandatoryPreferredMode => 'Preferred mode is mandatory';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get nicknameNonEditable => 'Nickname';

  @override
  String get fullName => 'Full name';

  @override
  String get mandatoryFullName => 'Full name is mandatory';
}
