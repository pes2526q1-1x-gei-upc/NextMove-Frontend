import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/main.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/auth_service.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/map_home_page.dart';

import 'package:nextmove_app/graphql/queries.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/email_address_page.dart';
import 'package:nextmove_app/src/funcionalidades/registro/dominio/email_address_page.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/presentacion/user_data_preferences_page.dart';
import 'package:provider/provider.dart';
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

  Future<void> _testQuery() async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getUserQuery),
      variables: {
        'id': '1', // ID hardcodeado para probar
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print('Error en query: ${result.exception.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result.exception.toString()}')),
      );
    } else {
      print('Resultado: ${result.data}');
      final userData = result.data?['User'];
      if (userData != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario: ${userData['nombre']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
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
              style: emailChecked ? TextStyle(color: Theme.of(context).disabledColor) : null,
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
                )
              ],
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final emailAddress = _emailController.text.trim();
                if (!emailChecked) {
                  try {
                    needsToRegister = !(await isEmailRegistered(emailAddress));
                    if (needsToRegister) {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.register),
                        content: Text(AppLocalizations.of(context)!.needsToRegister),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                  setState(() {
                    needsToRegister = needsToRegister;
                    emailChecked = true;
                  });
                  } on FirebaseAuthException catch (e) {
                      if (e.code == 'invalid-email') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.invalidEmail)),
                      );
                      return;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred(e.message ?? AppLocalizations.of(context)!.unknownError))),
                      );
                      return;
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred(e.toString()))),
                    );
                    return;
                  } 
                }
                else {
                  if (needsToRegister) {
                    final password = _passwordController.text;
                    final passwordValidationResult = isPasswordValid(password);
                    if (passwordValidationResult != PasswordValidationError.valid) {
                      String errorMessage = switch (passwordValidationResult) {
                        PasswordValidationError.tooShort =>
                          AppLocalizations.of(context)!.passwordTooShort,
                        PasswordValidationError.needsLowercase =>
                          AppLocalizations.of(context)!.passwordNeedsLowercase,
                        PasswordValidationError.needsUppercase =>
                          AppLocalizations.of(context)!.passwordNeedsUppercase,
                        PasswordValidationError.needsNumber =>
                          AppLocalizations.of(context)!.passwordNeedsNumber,
                        PasswordValidationError.needsSpecialCharacter =>
                          AppLocalizations.of(context)!.passwordNeedsSpecialCharacter,
                        _ => ''
                        };
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                      return;
                    }
                    try {
                      await createUserWithEmailAndPassword(
                        email: emailAddress,
                        password: password
                      );
                      print("Usuario creado con email y password");
                      final firebaseUser = FirebaseAuth.instance.currentUser!;
                      print("Firebase User ID: ${firebaseUser.uid}");
                      final firebaseToken = await firebaseUser.getIdToken();
                      print("Firebase Token: $firebaseToken");

                      final client = GraphQLProvider.of(context).value;
                      print("GraphQL Client obtenido");
                      final authService = AuthService(client);
                      print("AuthService creado");

                      final meData = await authService.getCurrentUser(); // Aquí se crea si no existe
                      print("Datos del usuario obtenidos: $meData");
                      if (meData == null) {
                        throw Exception("No se pudo obtener o crear el usuario en el backend");
                      }

                      // === Actualizar el provider ===
                      Provider.of<UserProvider>(context, listen: false).setUser(
                        meData,
                        firebaseUserId: firebaseUser.uid,
                        firebaseToken: firebaseToken,
                      );
                      print("UserProvider actualizado");

                      appKey.currentState?.setLoggedIn(true);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => UserDataPreferences(),
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
                        MaterialPageRoute(builder: (context) => MapHomePage()),
                        (route) => false,
                      );
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'wrong-password') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.wrongPassword)),
                        );
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred(e.message ?? AppLocalizations.of(context)!.unknownError))),
                        );
                      }
                    }
                  }
                }
              },
              child: emailChecked ?
                      (needsToRegister ? Text(AppLocalizations.of(context)!.register) :
                                         Text(AppLocalizations.of(context)!.signIn)) :
                        Text(AppLocalizations.of(context)!.continue_)
              ),
          ],
        ),
      ),
    );
  }
}