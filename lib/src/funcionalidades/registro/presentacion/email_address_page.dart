import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/main.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/map_home_page.dart';

import 'package:nextmove_app/src/funcionalidades/registro/datos/datasources/auth_remote_data_source.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/repositories/auth_repository_impl.dart';
import 'package:nextmove_app/src/funcionalidades/registro/dominio/email_address_page.dart';
import 'package:nextmove_app/src/funcionalidades/registro/dominio/usecases/check_email_existence_usecase.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/user_data_preferences_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/bloc/auth_bloc.dart';
// edit_user_data_preferences_page import removed - not used

class EmailAddressPage extends StatefulWidget {
  const EmailAddressPage({super.key});

  @override
  State<EmailAddressPage> createState() => _EmailAddressPageState();
}

class _EmailAddressPageState extends State<EmailAddressPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool emailChecked = false;
  bool needsToRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        checkEmailExistenceUseCase: CheckEmailExistenceUseCase(
          repository: AuthRepositoryImpl(AuthRemoteDataSourceImpl()),
        ),
      ),
      child: Builder(builder: (context) => _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.whatIsYourEmailAddress,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.emailAddress,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    readOnly: emailChecked,
                    style: emailChecked
                        ? TextStyle(color: Theme.of(context).disabledColor)
                        : null,
                  ),
                  if (emailChecked) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.password,
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    if (needsToRegister) ...[
                      Text(
                        AppLocalizations.of(context)!.passwordRequirements,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) async {
                      if (state is EmailIsNewState) {
                        needsToRegister = true;
                        emailChecked = true;
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(AppLocalizations.of(context)!.register),
                            content: Text(
                              AppLocalizations.of(context)!.needsToRegister,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        setState(() {});
                      } else if (state is EmailExistsState) {
                        needsToRegister = false;
                        emailChecked = true;
                        setState(() {});
                      } else if (state is AuthFailureState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.errorOccurred(
                                state.errorCode == 'invalid-email'
                                    ? AppLocalizations.of(context)!.invalidEmail
                                    : state.errorCode,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final emailAddress = _emailController.text.trim();
                      if (!emailChecked) {
                        // Dispatch BLoC event - the BlocListener will update UI
                        context.read<AuthBloc>().add(
                          CheckEmailExistenceEvent(email: emailAddress),
                        );
                      } else {
                        if (needsToRegister) {
                          final password = _passwordController.text;
                          final passwordValidationResult = isPasswordValid(
                            password,
                          );
                          if (passwordValidationResult !=
                              PasswordValidationError.valid) {
                            String
                            errorMessage = switch (passwordValidationResult) {
                              PasswordValidationError.tooShort =>
                                AppLocalizations.of(context)!.passwordTooShort,
                              PasswordValidationError.needsLowercase =>
                                AppLocalizations.of(
                                  context,
                                )!.passwordNeedsLowercase,
                              PasswordValidationError.needsUppercase =>
                                AppLocalizations.of(
                                  context,
                                )!.passwordNeedsUppercase,
                              PasswordValidationError.needsNumber =>
                                AppLocalizations.of(
                                  context,
                                )!.passwordNeedsNumber,
                              PasswordValidationError.needsSpecialCharacter =>
                                AppLocalizations.of(
                                  context,
                                )!.passwordNeedsSpecialCharacter,
                              _ => '',
                            };
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage)),
                            );
                            return;
                          }
                          try {
                            createUserWithEmailAndPassword(
                              email: emailAddress,
                              password: password,
                            );
                            appKey.currentState?.setLoggedIn(true);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const UserDataPreferencesPage(),
                              ),
                            );
                          } catch (e) {
                            print(e);
                          }
                        } else {
                          final password = _passwordController.text;
                          try {
                            await signInWithEmailAndPassword(
                              email: emailAddress,
                              password: password,
                            );
                            appKey.currentState?.setLoggedIn(true);
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => MapHomePage(),
                              ),
                              (route) => false,
                            );
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'wrong-password') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.wrongPassword,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.errorOccurred(
                                      e.message ??
                                          AppLocalizations.of(
                                            context,
                                          )!.unknownError,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    child: emailChecked
                        ? (needsToRegister
                              ? Text(AppLocalizations.of(context)!.register)
                              : Text(AppLocalizations.of(context)!.signIn))
                        : Text(AppLocalizations.of(context)!.continue_),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
