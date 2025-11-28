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
          // Close dialog first
          Navigator.pop(context);

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorCode),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AccountDeletedState) {
          // Close dialog first
          Navigator.pop(context);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.accountDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to welcome page and clear navigation stack
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
              // Check if user is Google user
              Builder(
                builder: (context) {
                  final user = FirebaseAuth.instance.currentUser;
                  final isGoogleUser =
                      user?.providerData.any(
                        (info) => info.providerId == 'google.com',
                      ) ??
                      false;

                  if (isGoogleUser) {
                    // Google users don't need password field
                    return Text(
                      'You will be prompted to sign in with Google to confirm.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    );
                  } else {
                    // Email/password users need to enter password
                    return TextField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        isDense: true,
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

                      // Google users don't need password, others do
                      if (!isGoogleUser && password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.password),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // Dispatch delete event (password can be empty for Google users)
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
