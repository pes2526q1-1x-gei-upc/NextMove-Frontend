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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Título grande y minimalista
                        Text(
                          l10n.whatIsYourEmailAddress,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Campo de Email
                        EmailAddressInputWidget(emailController: _emailController),
                        
                        // Lógica condicional para mostrar password
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is EmailIsNewState || state is EmailExistsWithoutGoogleState) {
                               return Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const SizedBox(height: 20),
                                   PasswordInputWidget(
                                     passwordController: _passwordController,
                                   ),
                                   if (state is EmailIsNewState) ...[
                                     const SizedBox(height: 8),
                                     Padding(
                                       padding: const EdgeInsets.only(left: 4),
                                       child: Text(
                                         l10n.passwordRequirements,
                                         style: theme.textTheme.bodySmall?.copyWith(
                                           color: theme.disabledColor,
                                         ),
                                       ),
                                     ),
                                   ],
                                 ],
                               );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        const SizedBox(height: 20),

                        // Listener de eventos
                        BlocListener<AuthBloc, AuthState>(
                          listener: (context, state) async {
                            switch (state) {
                              case EmailIsNewState(): // Usuario nuevo
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                  Navigator.of(context).pop(); 
                                }
                                setState(() {});
                              case EmailExistsWithoutGoogleState(): // Usuario existe
                                setState(() {}); 
                              case AuthFailureState(): // Error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: theme.colorScheme.error,
                                    content: Text(switch (state.errorCode) {
                                      'invalid-email' => l10n.invalidEmail,
                                      'wrong-password' => l10n.wrongPassword,
                                      '' => l10n.unknownError,
                                      _ => l10n.errorOccurred(state.errorCode),
                                    }, style: const TextStyle(color: Colors.white)),
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
                        
                        const Spacer(),
                        
                        const SizedBox(height: 20),
                        
                        // Botón Continuar
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ContinueButton(
                            emailController: _emailController,
                            passwordController: _passwordController,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
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
    final theme = Theme.of(context);
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
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
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
           Widget textWidget;
           if (state is AuthInitial) {
             textWidget = Text(l10n.continue_, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
           } else if (state is EmailIsNewState) {
             textWidget = Text(l10n.register, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
           } else if (state is EmailExistsWithoutGoogleState) {
             textWidget = Text(l10n.signIn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
           } else {
             textWidget = Text(l10n.continue_, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
           }
           
           return textWidget;
        }
      ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.all(20),
      ),
      obscureText: true,
      style: const TextStyle(fontSize: 16),
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
    final isReadOnly = context.watch<AuthBloc>().state is! AuthInitial;
    
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: l10n.emailAddress,
        hintText: 'name@example.com',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: isReadOnly ? Theme.of(context).disabledColor.withOpacity(0.1) : Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.all(20),
      ),
      keyboardType: TextInputType.emailAddress,
      readOnly: isReadOnly,
      style: isReadOnly
          ? TextStyle(color: Theme.of(context).disabledColor)
          : const TextStyle(fontSize: 16),
    );
  }
}
