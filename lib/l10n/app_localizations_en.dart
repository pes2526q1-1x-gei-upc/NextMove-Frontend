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
}
