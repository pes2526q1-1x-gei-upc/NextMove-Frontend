import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/bloc/auth_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/welcome_page.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  String? _errorMessage; 

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          setState(() {
            _errorMessage = state.errorCode;
          });

        } else if (state is AccountDeletedState) {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.accountDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WelcomePage()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.deleteAccount,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAccountConfirmation,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              const SizedBox(height: 20),
              
              Builder(
                builder: (context) {
                  final user = FirebaseAuth.instance.currentUser;
                  final isGoogleUser =
                      user?.providerData.any(
                        (info) => info.providerId == 'google.com',
                      ) ??
                      false;

                  if (isGoogleUser) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You will be prompted to sign in with Google to confirm.',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              switch (_errorMessage!) {
                                "wrong-password" => l10n.wrongPassword,
                                "user-mismatch" => l10n.userMismatch,
                                _ => _errorMessage!,
                              },
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  } else {
                    // Usuarios con Email/Password
                    return TextField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      enabled: !isLoading,
                      // Limpiamos el error en cuanto el usuario escribe algo nuevo
                      onChanged: (value) {
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        isDense: true,
                        errorText: switch (_errorMessage) {
                          "wrong-password" => l10n.wrongPassword,
                          null => null,
                          _ => _errorMessage,
                        },
                        errorMaxLines: 6,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => _isObscure = !_isObscure),
                        ),
                      ),
                    );
                  }
                },
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: isLoading ? Colors.grey : Colors.grey[700],
                ),
              ),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      final user = FirebaseAuth.instance.currentUser;
                      final isGoogleUser =
                          user?.providerData.any(
                            (info) => info.providerId == 'google.com',
                          ) ??
                          false;
                      final password = _passwordController.text;

                      if (!isGoogleUser && password.isEmpty) {
                        setState(() {
                          _errorMessage = l10n.password;
                        });
                        return;
                      }

                      setState(() {
                         _errorMessage = null;
                      });

                      context.read<AuthBloc>().add(
                        DeleteAccountEvent(password: password),
                      );
                    },
              child: Text(
                l10n.delete,
                style: TextStyle(
                  color: isLoading ? Colors.grey : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}