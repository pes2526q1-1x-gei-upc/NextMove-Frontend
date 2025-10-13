import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/MapHomePage.dart';
import 'l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/RegisterPage.dart';

final GlobalKey<_NextMoveAppState> appKey = GlobalKey<_NextMoveAppState>();

void main() {
  runApp(NextMoveApp(key: appKey));
}

class NextMoveApp extends StatefulWidget {
  const NextMoveApp({super.key});

  @override
  State<NextMoveApp> createState() => _NextMoveAppState();
}

class _NextMoveAppState extends State<NextMoveApp> {
  bool isLoggedIn = false;

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLoggedIn ? MapHomePage() : RegisterPage(),
    );
  }
}