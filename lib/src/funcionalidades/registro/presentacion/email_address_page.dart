import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/main.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/MapHomePage.dart';

import 'package:nextmove_app/graphql/queries.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
            
            // Button to test GraphQL query
            ElevatedButton(
              onPressed: _testQuery,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Probar Query GraphQL'),
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
                    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: emailAddress,
                      password: "1111111",
                    );
                    await credential.user?.delete();
                    setState(() {
                      needsToRegister = true;
                      emailChecked = true;
                    });
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
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'email-already-in-use') {
                      setState(() {
                        needsToRegister = false;
                        emailChecked = true;
                      });
                    } else if (e.code == 'invalid-email') {
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
                    if (password.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.passwordTooShort)),
                      );
                      return;
                    }
                    if (!RegExp(r'[a-z]').hasMatch(password)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.passwordNeedsLowercase)),
                      );
                      return;
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(password)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.passwordNeedsUppercase)),
                      );
                      return;
                    }
                    if (!RegExp(r'[0-9]').hasMatch(password)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.passwordNeedsNumber)),
                      );
                      return;
                    }
                    if (!RegExp(r'[!@#\$&*~%^(),.?":{}|<>]').hasMatch(password)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.passwordNeedsSpecialCharacter)),
                      );
                      return;
                    }
                    try {
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: emailAddress,
                        password: password,
                      );
                      appKey.currentState?.setLoggedIn(true);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MapHomePage()),
                      );
                    } catch (e) {
                      print(e);
                    }
                  } else {
                    final password = _passwordController.text;
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
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
                        print('Wrong password provided for that user.');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.wrongPassword)),
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