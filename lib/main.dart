import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/welcome_page.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/MapHomePage.dart';
import 'l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'config/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

final GlobalKey<_NextMoveAppState> appKey = GlobalKey<_NextMoveAppState>();

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
  runApp(NextMoveApp(key: appKey));
}

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
      .authenticate();

  if (googleUser == null) {
    return Future.error('Sign in aborted by user');
  }

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = googleUser.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

class NextMoveApp extends StatefulWidget {
  const NextMoveApp({super.key});

  @override
  State<NextMoveApp> createState() => _NextMoveAppState();
}

class _NextMoveAppState extends State<NextMoveApp> {
  bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
  void setLoggedIn(bool value) {
    setState(() {
      isLoggedIn = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextMove',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // Fallback to English
        return const Locale('en');
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: isLoggedIn ? MapHomePage() : WelcomePage(),
    );
  }
}
