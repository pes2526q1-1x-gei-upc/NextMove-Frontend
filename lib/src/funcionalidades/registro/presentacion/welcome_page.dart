import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/main.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/email_address_page.dart';

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
                onPressed: () {
                  signInWithGoogle();
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}