import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/bloc/auth_bloc.dart';
import 'package:provider/provider.dart';

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

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l10n.deleteAccount, 
        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
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
          TextField(
            controller: _passwordController,
            obscureText: _isObscure,
            decoration: InputDecoration(
              labelText: l10n.password, 
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            // DeleteAccountEvent
            final password = _passwordController.text;

            if (password.isNotEmpty) {
              context.read<AuthBloc>().add(DeleteAccountEvent(password: password));

              if (state )
              Navigator.pop(context); 
            } else {
              debugPrint("La contraseña está vacía");
            }
            Navigator.pop(context); 
          },
          child: Text(
            l10n.delete,
            style: const TextStyle(
              color: Colors.redAccent, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }
}