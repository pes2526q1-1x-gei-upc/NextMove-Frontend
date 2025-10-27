import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/MapHomePage.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/welcome_page.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/email_address_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/auth_service.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var signInButtonsWidth = MediaQuery.of(context).size.width * (2/3);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.welcomeTo('NextMove'),
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SignInButton(
                Buttons.Email,
                width: signInButtonsWidth,
                text: AppLocalizations.of(context)!.useEmail,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EmailAddressPage()),
                  );
                }
              ),
              SignInButton(
                Buttons.Google,
                width: signInButtonsWidth,
                text: AppLocalizations.of(context)!.signInWithGoogle,
                onPressed: () async {
                  final userCredential = await signInWithGoogle();
                  final firebaseToken = await userCredential.user?.getIdToken();
                  final firebaseUserId = userCredential.user?.uid;

                  // obtener el usuario mediante la API y guardarlo en Provider
                  final client = GraphQLProvider.of(context).value;
                  final authService = AuthService(client);

                  try {
                    final meData = await authService.getCurrentUser();
                    if (meData != null && firebaseUserId != null) {
                      debugPrint("Hey acabo de guardar los siguientes datos:");
                      debugPrint("Firebase User ID: $firebaseUserId");
                      debugPrint("User Data: $meData");
                      Provider.of<UserProvider>(context, listen: false).setUser(
                        meData,
                        firebaseUserId: firebaseUserId,
                        firebaseToken: firebaseToken,
                      );
                    }
                  } catch (e) {
                    print("Error cargando usuario GraphQL: $e");
                  }
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MapHomePage()),
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}