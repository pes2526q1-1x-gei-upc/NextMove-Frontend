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
  String get wrongPassword =>
      'The password is incorrect. If you used this email address to sign up with Google, please sign in with Google.';

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

  @override
  String errorOccurred(String error) {
    return 'An error has occurred: $error';
  }

  @override
  String get unknownError => 'Unknown error';

  @override
  String get searchStation => 'Search for a station...';

  @override
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

  @override
  String get saveChangesError => 'Error saving changes.';

  @override
  String get bicycle => 'Bicycle';

  @override
  String get car => 'Car';

  @override
  String get finishRegistration => 'Finish registration';

  @override
  String get userNotLoadedMessage => 'The user has not been loaded correctly.';

  @override
  String get information => 'Information';

  @override
  String get logOut => 'Log out';

  @override
  String get creatingYourAccount => 'Creating your account...';

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String get loadingUserProfile => 'Loading user profile...';

  @override
  String get unknownState => 'Unknown state';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmLogOut => 'Are you sure you want to log out?';

  @override
  String get contactAndBioInfo => 'Contact and bio information';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get loading => 'Loading...';

  @override
  String get waitAMoment => 'Please wait a moment';

  @override
  String get hi => 'Hi, ';

  @override
  String get ops => 'Oops!';

  @override
  String get account => 'Account';

  @override
  String get accountDetails => 'Account details';

  @override
  String get bloquedUsers => 'Blocked users';

  @override
  String get noBloquedUsers => 'You have no blocked users.';

  @override
  String get unblock => 'Unblock';

  @override
  String get settings => 'Settings';

  @override
  String get appLanguage => 'App language';

  @override
  String get notifications => 'Notifications';

  @override
  String get appearance => 'Appearance';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get preliminarVersion => 'Preliminary version';

  @override
  String get searchByNickname => 'Search by nickname';

  @override
  String get noUsersFound => 'No user found with that nickname.';

  @override
  String get noFriendsAdded => 'You have no friends added yet.';

  @override
  String get results => 'RESULTS';

  @override
  String get yourFriends => 'YOUR FRIENDS';

  @override
  String friendAdded(String nickname) {
    return '$nickname has been added to your friends.';
  }

  @override
  String get friends => 'Friends';

  @override
  String get memberSince => 'Member since';

  @override
  String get deleteFriendship => 'Delete friendship';

  @override
  String deleteFriendConfirmation(String nickname) {
    return 'Are you sure you want to delete $nickname from your friends?';
  }

  @override
  String get delete => 'Delete';

  @override
  String deletedFriend(String nickname) {
    return 'You have deleted $nickname from your friends.';
  }

  @override
  String get deleteFriend => 'Delete friendship';

  @override
  String get blockUser => 'Block user';

  @override
  String blockUserConfirmation(String nickname) {
    return 'Are you sure you want to block $nickname? You won\'t be able to see their profile or interact with them.';
  }

  @override
  String get block => 'Block';

  @override
  String get minCharsSearchHint =>
      'Please enter at least 3 characters to search.';

  @override
  String get anyStationsFound => 'No results were found for your search.';

  @override
  String get errorSavingRoute => 'Error saving route';

  @override
  String get notEnoughPointsToRecordTrack =>
      'Not enough points were recorded to save the recorded route.';

  @override
  String get routeHistory => 'Recorded route history';

  @override
  String get noRoutesFound => 'No recorded routes were found.';

  @override
  String get distance => 'Distance';

  @override
  String get avgSpeed => 'Average speed';

  @override
  String get routeStatistics => 'Route statistics';

  @override
  String get noRouteDataAvailable => 'No route data available.';

  @override
  String get routeRecording => 'Route recording';

  @override
  String get duration => 'Duration';

  @override
  String get averageSpeed => 'Average speed';

  @override
  String get maxSpeed => 'Max speed';

  @override
  String get elevation => 'Elevation';

  @override
  String get elevationGain => 'Elevation gain';

  @override
  String get elevationLoss => 'Elevation loss';

  @override
  String get environmentalImpact => 'Environmental impact';

  @override
  String get co2Saved => 'CO₂ saved';

  @override
  String get caloriesBurned => 'Calories burned';

  @override
  String get currentSpeed => 'Current speed';

  @override
  String get stopRecording => 'Stop recording';

  @override
  String get opinions => 'Reviews';

  @override
  String get station => 'Station';

  @override
  String get seeOpinions => 'See reviews';

  @override
  String get withoutOpinions => 'Without reviews';

  @override
  String get rate => 'Rate';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get normal => 'Normal';

  @override
  String get mechanical => 'Mechanical';

  @override
  String get electric => 'Electric';

  @override
  String get free => 'Free';

  @override
  String get charge => 'Charge';

  @override
  String get reviewStation => 'Review Station';

  @override
  String get writeYourOpinion => 'Write your opinion (optional)';

  @override
  String get sendReview => 'Submit review';

  @override
  String get excellent => 'Excellent';

  @override
  String get veryGood => 'Very good';

  @override
  String get good => 'Good';

  @override
  String get regular => 'Fair';

  @override
  String get bad => 'Poor';

  @override
  String get thankYouForYourReview => 'Thank you for your review!';

  @override
  String get errorLoadingReviews => 'Error loading reviews';

  @override
  String get retry => 'Retry';

  @override
  String get firstToReview => 'Be the first to review this station!';

  @override
  String get editReview => 'Edit review';

  @override
  String get sureActionConfirmation =>
      'This action cannot be undone. Are you sure you want to proceed?';

  @override
  String get deletedReview => 'You have deleted your review.';

  @override
  String get updateReview => 'Update review';

  @override
  String get updatedReview => 'Your review has been updated.';

  @override
  String get needsToSignInWithGoogle =>
      'This email is registered with Google. Please sign in with Google.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account? This action cannot be undone and all your data will be lost.';

  @override
  String get accountDeleted => 'Your account has been successfully deleted.';

  @override
  String get errorDeletingAccount => 'Error deleting account.';

  @override
  String get accountDeletedSuccessfully =>
      'The account has been deleted successfully.';

  @override
  String get userMismatch => 'The user does not match the current user.';
}
