import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/user_data_preferences_page.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/bloc/auth_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/email_address_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var signInButtonsWidth = MediaQuery.of(context).size.width * (2 / 3);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(switch (state.errorCode) {
                'invalid-email' => l10n.invalidEmail,
                'wrong-password' => l10n.wrongPassword,
                '' => l10n.unknownError,
                _ => l10n.errorOccurred(state.errorCode),
              })),
            );
          } else if (state is UserNeedsProfileSetupState) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const UserDataPreferencesPage(),
              ),
            );
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.welcomeTo('NextMove'),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                EmailSignInButton(signInButtonsWidth: signInButtonsWidth),
                GoogleSignInButton(signInButtonsWidth: signInButtonsWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.signInButtonsWidth});

  final double signInButtonsWidth;

  @override
  Widget build(BuildContext context) {
    return SignInButton(
      Buttons.Google,
      width: signInButtonsWidth,
      text: AppLocalizations.of(context)!.signInWithGoogle,
      onPressed: () {
        context.read<AuthBloc>().add(SignInWithGoogleEvent());
      },
    );
  }
}

class EmailSignInButton extends StatelessWidget {
  const EmailSignInButton({super.key, required this.signInButtonsWidth});

  final double signInButtonsWidth;

  @override
  Widget build(BuildContext context) {
    return SignInButton(
      Buttons.Email,
      width: signInButtonsWidth,
      text: AppLocalizations.of(context)!.useEmail,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const EmailAddressPage()),
        );
      },
    );
  }
}
