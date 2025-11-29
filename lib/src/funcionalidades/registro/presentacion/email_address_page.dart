import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/main.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/user_data_preferences_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/bloc/auth_bloc.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';

class EmailAddressPage extends StatefulWidget {
  const EmailAddressPage({super.key});

  @override
  State<EmailAddressPage> createState() => _EmailAddressPageState();
}

class _EmailAddressPageState extends State<EmailAddressPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Builder(builder: (context) => _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.whatIsYourEmailAddress,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  EmailAddressInputWidget(emailController: _emailController),
                  if (context.read<AuthBloc>().state is EmailIsNewState ||
                      context.read<AuthBloc>().state
                          is EmailExistsWithoutGoogleState) ...[
                    const SizedBox(height: 16),
                    PasswordInputWidget(
                      passwordController: _passwordController,
                    ),
                    if (context.read<AuthBloc>().state is EmailIsNewState) ...[
                      Text(
                        l10n.passwordRequirements,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) async {
                      switch (state) {
                        case EmailIsNewState(): // Usuario nuevo
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.register),
                              content: Text(l10n.needsToRegister),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          setState(() {});
                        case EmailExistsWithGoogleState(): // Usuario con Google
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.signInWithGoogle),
                              content: Text(l10n.needsToSignInWithGoogle),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).pop(); // Tornar a la pantalla d'inici (WelcomePage)
                          }
                          setState(() {});
                        case EmailExistsWithoutGoogleState(): // Usuario existe
                          setState(() {});
                        case AuthFailureState(): // Error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(switch (state.errorCode) {
                                'invalid-email' => l10n.invalidEmail,
                                'wrong-password' => l10n.wrongPassword,
                                '' => l10n.unknownError,
                                _ => l10n.errorOccurred(state.errorCode),
                              }),
                            ),
                          );

                        case AuthSuccessState(): // Ya iniciado sesion
                          {
                            if (state.meData != null) {
                              Provider.of<UserProvider>(
                                context,
                                listen: false,
                              ).setUser(
                                state.meData!,
                                firebaseUserId: state.firebaseUserId,
                                firebaseToken: state.firebaseToken,
                              );
                            }
                            appKey.currentState?.setLoggedIn(true);

                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          }

                        case UserNeedsProfileSetupState(): // Onboarding
                          appKey.currentState?.setLoggedIn(true);
                          Provider.of<UserProvider>(
                            context,
                            listen: false,
                          ).setEmailPwd(
                            _emailController.text,
                            _passwordController.text,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (pageContext) =>
                                  const UserDataPreferencesPage(),
                            ),
                          );
                        default:
                          break;
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                  ContinueButton(
                    emailController: _emailController,
                    passwordController: _passwordController,
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

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    super.key,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) : _emailController = emailController,
       _passwordController = passwordController;

  final TextEditingController _emailController;
  final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ElevatedButton(
      onPressed: () async {
        final emailAddress = _emailController.text.trim();
        if (context.read<AuthBloc>().state is AuthInitial) {
          context.read<AuthBloc>().add(
            CheckEmailExistenceEvent(email: emailAddress),
          );
        } else {
          if (context.read<AuthBloc>().state is EmailIsNewState) {
            try {
              Provider.of<UserProvider>(
                context,
                listen: false,
              ).setEmailPwd(_emailController.text, _passwordController.text);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (pageContext) => const UserDataPreferencesPage(),
                ),
              );
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
          } else {
            final password = _passwordController.text;
            context.read<AuthBloc>().add(
              SignInWithEmailEvent(email: emailAddress, password: password),
            );
          }
        }
      },
      child: switch (context.read<AuthBloc>().state) {
        AuthInitial _ => Text(l10n.continue_),
        EmailIsNewState _ => Text(l10n.register),
        EmailExistsWithoutGoogleState _ => Text(l10n.signIn),
        _ => const Text(''),
      },
    );
  }
}

class PasswordInputWidget extends StatelessWidget {
  const PasswordInputWidget({
    super.key,
    required TextEditingController passwordController,
  }) : _passwordController = passwordController;

  final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: l10n.password,
        border: const OutlineInputBorder(),
      ),
      obscureText: true,
    );
  }
}

class EmailAddressInputWidget extends StatelessWidget {
  const EmailAddressInputWidget({
    super.key,
    required TextEditingController emailController,
  }) : _emailController = emailController;

  final TextEditingController _emailController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: l10n.emailAddress,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      readOnly: context.read<AuthBloc>().state is! AuthInitial,
      style: context.read<AuthBloc>().state is! AuthInitial
          ? TextStyle(color: Theme.of(context).disabledColor)
          : null,
    );
  }
}
