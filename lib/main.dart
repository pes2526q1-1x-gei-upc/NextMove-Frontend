import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_details.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_list.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/welcome_page.dart';

import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/MapHomePage.dart';
import 'l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/welcome_page.dart';
import 'package:nextmove_app/config/graphql_config.dart';


final GlobalKey<_NextMoveAppState> appKey = GlobalKey<_NextMoveAppState>();

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  GraphQLConfig.initializeClient();
  runApp(NextMoveApp(key: appKey));
}

class NextMoveApp extends StatefulWidget {
  const NextMoveApp({super.key});

  @override
  State<NextMoveApp> createState() => _NextMoveAppState();
}

class _NextMoveAppState extends State<NextMoveApp> {
  bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    client = GraphQLConfig.initializeClient();
  }
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
          // Fallback to English
          return const Locale('en');
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: StationList(stationType: StationType.bicycle),
        //StationDetailsPage(stationID: "125", stationType: StationType.bicycle)/*isLoggedIn ? MapHomePage() : WelcomePage()*/,
      ),
      home:  MapHomePage() ,
    );
  }
}