import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/map_home_page.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/presentacion/user_data_preferences_page.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/welcome_page.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/email_address_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/graphql/queries.dart';

import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/auth_service.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var signInButtonsWidth = MediaQuery.of(context).size.width * (2 / 3);
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
                },
              ),
              SignInButton(
                Buttons.Google,
                width: signInButtonsWidth,
                text: AppLocalizations.of(context)!.signInWithGoogle,
                onPressed: () async {
                  try {
                    final userCredential = await signInWithGoogle();
                    if (userCredential.user == null) return;

                    final firebaseUserId = userCredential.user!.uid;
                    final firebaseToken = await userCredential.user!
                        .getIdToken();
                    final email = userCredential.user!.email;
                    final name = userCredential.user!.displayName;

                    // ✅ Detectar si es usuario nuevo
                    final isNewUser =
                        userCredential.additionalUserInfo?.isNewUser ?? false;
                    debugPrint("¿Es usuario nuevo? $isNewUser");

                    final client = GraphQLProvider.of(context).value;
                    final authService = AuthService(client);

                    // Hacer upsert con needsToRegister solo si es nuevo
                    await authService.upsertUserFromFirebase(
                      firebaseUid: firebaseUserId,
                      email: email,
                      name: name,
                      needsToRegister: isNewUser,
                    );

                    final meData = await authService.getCurrentUser();

                    if (meData != null) {
                      Provider.of<UserProvider>(context, listen: false).setUser(
                        meData,
                        firebaseUserId: firebaseUserId,
                        firebaseToken: firebaseToken,
                      );
                    }

                    if (context.mounted) {
                      // ✅ Usar operador ?? para manejar null
                      final needsToRegister =
                          meData?['needsToRegister'] ?? true;
                      debugPrint("needsToRegister: $needsToRegister");

                      if (needsToRegister) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const UserDataPreferences(),
                          ),
                        );
                      } else {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const MapHomePage(),
                          ),
                          (route) => false,
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint("Error login: $e");
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
